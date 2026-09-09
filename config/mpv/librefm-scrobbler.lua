--[[
librefm-scrobbler.lua - offline-capable Libre.fm scrobbler for mpv.

IMPORTANT: place this file somewhere mpv does NOT auto-load (i.e. NOT
directly in ~/.config/mpv/scripts/), then load it only from your music
profile in mpv.conf:

    [music]
    video=no
    stop-screensaver=no
    scripts-append=~/.config/mpv/scripts-available/librefm-scrobbler.lua

This way the script is only active when you actually launch mpv with
--profile=music - any other use of mpv (watching a video, a YouTube TUI
scraper, etc.) never loads it and can never be scrobbled.

Configure your credentials in:
    ~/.config/mpv/script-opts/librefm-scrobbler.conf
(see librefm-scrobbler.conf.example for the format). Keep credentials
out of the command line / mpv.conf itself - anything on the command
line is visible to other local users via `ps`.

Requires: curl, md5sum (both standard on virtually every Linux system).

Behaviour:
- Scrobbles once 80% of a track has played, or after 4 minutes,
  whichever comes first (both configurable).
- Tracks shorter than 30s are never scrobbled (protocol convention).
- Detects the same track being repeated/looped, by watching for
  playback position jumping back near the start.
- If a scrobble attempt fails (offline, server hiccup), it's queued to
  disk and retried in the background with a backoff.
- Logs successful scrobbles in mpdscribble's own plain-text format, so
  you can point log_file at the same file mpdscribble uses:
      2026-09-03T22:06:58-0300 Big Thief - Not
--]]

local mp = require 'mp'
local options = require 'mp.options'
local utils = require 'mp.utils'
local msg = require 'mp.msg'

-- =====================================================================
-- CONFIGURATION (overridable via script-opts/librefm-scrobbler.conf)
-- =====================================================================
local opts = {
    username = "YOUR_USERNAME",
    password = "YOUR_PASSWORD",

    log_file = "~/.cache/scrobbling-log",
    cache_file = "~/.cache/librefm-scrobbler/queue.json",

    scrobble_fraction = 0.8,        -- scrobble once this fraction of the track has played...
    scrobble_max_seconds = 240,     -- ...or after this many seconds, whichever comes first
    min_track_duration = 30,        -- tracks shorter than this are never scrobbled

    retry_interval_seconds = 60,    -- don't retry a failed offline-queue submission more often than this
    tick_interval = 2,              -- how often to check playback position, in seconds

    repeat_reset_threshold = 3,         -- position must drop below this to count as "back near the start"
    repeat_min_prior_position = 10,     -- ...and must have been at least this far in beforehand
}
options.read_options(opts, "librefm-scrobbler")

local function expand_home(path)
    if path:sub(1, 1) == "~" then
        local home = os.getenv("HOME") or ""
        return home .. path:sub(2)
    end
    return path
end
opts.log_file = expand_home(opts.log_file)
opts.cache_file = expand_home(opts.cache_file)

local CONFIGURED = opts.username ~= "" and opts.username ~= "YOUR_USERNAME"
if not CONFIGURED then
    msg.warn("librefm-scrobbler: no credentials configured (see script-opts/librefm-scrobbler.conf) - disabled")
end

local function ensure_parent_dir(path)
    local dir = path:match("^(.*)/[^/]+$")
    if dir and dir ~= "" then
        mp.command_native({ name = "subprocess", args = { "mkdir", "-p", dir }, capture_stdout = false })
    end
end
if CONFIGURED then
    ensure_parent_dir(opts.log_file)
    ensure_parent_dir(opts.cache_file)
end

-- =====================================================================
-- STATE
-- =====================================================================
local session_id = nil
local submission_url = nil

local state = {
    artist = nil,
    title = nil,
    album = nil,
    duration = 0,
    started_at = nil,
    scrobble_triggered = false,
    last_position = nil,
}

local last_flush_attempt = 0
local check_and_trigger  -- forward declaration (defined below, used above its definition)

-- =====================================================================
-- HELPERS: MD5 and Libre.fm API (both shell out - no Lua deps available)
-- =====================================================================
local function md5sum(str)
    local res = mp.command_native({
        name = "subprocess",
        args = { "bash", "-c", "printf '%s' \"$1\" | md5sum | cut -d' ' -f1", "_", str },
        capture_stdout = true,
    })
    if res and res.status == 0 and res.stdout then
        return (res.stdout:gsub("%s+$", ""))
    end
    return nil
end

local function handshake()
    local timestamp = os.time()
    local p_md5 = md5sum(opts.password)
    if not p_md5 then
        msg.error("librefm-scrobbler: could not compute password hash (is md5sum installed?)")
        return false
    end
    local auth = md5sum(p_md5 .. tostring(timestamp))
    if not auth then
        msg.error("librefm-scrobbler: could not compute auth hash")
        return false
    end

    local res = mp.command_native({
        name = "subprocess",
        args = {
            "curl", "-s", "--max-time", "10", "--get",
            "--data-urlencode", "hs=true",
            "--data-urlencode", "p=1.2",
            "--data-urlencode", "c=tst",
            "--data-urlencode", "v=1.0",
            "--data-urlencode", "u=" .. opts.username,
            "--data-urlencode", "t=" .. tostring(timestamp),
            "--data-urlencode", "a=" .. auth,
            "http://turtle.libre.fm/",
        },
        capture_stdout = true,
    })
    if not res or res.status ~= 0 or not res.stdout then
        msg.warn("librefm-scrobbler: handshake failed (network/curl error)")
        return false
    end

    local lines = {}
    for line in res.stdout:gmatch("[^\r\n]+") do table.insert(lines, line) end

    if lines[1] and lines[1]:sub(1, 2) == "OK" then
        session_id = lines[2]
        submission_url = lines[4]
        msg.info("librefm-scrobbler: handshake successful")
        return true
    else
        msg.error("librefm-scrobbler: handshake rejected: " .. (lines[1] or "no response"))
        return false
    end
end

local function submit_batch(tracks)
    if not session_id and not handshake() then
        return false
    end

    local args = { "curl", "-s", "--max-time", "15" }
    local function add(k, v) table.insert(args, "--data-urlencode"); table.insert(args, k .. "=" .. tostring(v)) end
    add("s", session_id)
    for i, t in ipairs(tracks) do
        local idx = i - 1
        add(string.format("a[%d]", idx), t.artist)
        add(string.format("t[%d]", idx), t.title)
        add(string.format("i[%d]", idx), t.timestamp)
        add(string.format("o[%d]", idx), "P")
        add(string.format("b[%d]", idx), t.album or "")
        add(string.format("l[%d]", idx), t.duration or "")
    end
    table.insert(args, submission_url)

    local res = mp.command_native({ name = "subprocess", args = args, capture_stdout = true })
    if not res or res.status ~= 0 or not res.stdout then
        msg.warn("librefm-scrobbler: scrobble submission failed (network/curl error)")
        return false
    end

    local body = res.stdout
    if body:sub(1, 2) == "OK" then
        msg.info(string.format("librefm-scrobbler: scrobbled batch of %d track(s)", #tracks))
        return true
    elseif body:sub(1, 10) == "BADSESSION" then
        msg.warn("librefm-scrobbler: session expired, re-handshaking...")
        session_id = nil
        if handshake() then return submit_batch(tracks) end
        return false
    else
        msg.error("librefm-scrobbler: server rejected batch: " .. body)
        return false
    end
end

-- =====================================================================
-- HELPERS: offline queue + readable log
-- =====================================================================
local function load_queue()
    local f = io.open(opts.cache_file, "r")
    if not f then return {} end
    local content = f:read("*a")
    f:close()
    if not content or content == "" then return {} end
    local ok, data = pcall(utils.parse_json, content)
    if ok and type(data) == "table" then return data end
    return {}
end

local function save_queue(queue)
    local tmp = opts.cache_file .. ".tmp"
    local f = io.open(tmp, "w")
    if not f then
        msg.error("librefm-scrobbler: could not write queue file")
        return
    end
    f:write(utils.format_json(queue))
    f:close()
    os.rename(tmp, opts.cache_file)
end

local function log_scrobbled(track)
    local f = io.open(opts.log_file, "a")
    if not f then
        msg.error("librefm-scrobbler: could not write to log file: " .. opts.log_file)
        return
    end
    local stamp = os.date("%Y-%m-%dT%H:%M:%S%z")
    f:write(string.format("%s %s - %s\n", stamp, track.artist, track.title))
    f:close()
end

-- =====================================================================
-- CORE SCROBBLE LOGIC
-- =====================================================================
local function scrobble_threshold(duration)
    return math.min(duration * opts.scrobble_fraction, opts.scrobble_max_seconds)
end

local function trigger_scrobble()
    if state.scrobble_triggered or not state.artist then return end
    state.scrobble_triggered = true

    local track = {
        artist = state.artist,
        title = state.title,
        album = state.album or "",
        duration = state.duration,
        timestamp = state.started_at,
    }
    msg.info(string.format("librefm-scrobbler: qualifying threshold met: %s - %s", track.artist, track.title))

    if submit_batch({ track }) then
        log_scrobbled(track)
    else
        local q = load_queue()
        table.insert(q, track)
        save_queue(q)
        msg.info("librefm-scrobbler: offline - queued: " .. track.artist .. " - " .. track.title)
    end
end

check_and_trigger = function()
    if not state.artist or state.scrobble_triggered then return end
    if state.duration < opts.min_track_duration then return end
    local pos = mp.get_property_number("time-pos", 0)
    if pos >= scrobble_threshold(state.duration) then
        trigger_scrobble()
    end
end

local function start_new_play(artist, title, album, duration)
    state.artist = artist
    state.title = title
    state.album = album
    state.duration = duration
    state.started_at = os.time()
    state.scrobble_triggered = false
    state.last_position = nil
end

local function maybe_flush_queue()
    local q = load_queue()
    if #q == 0 then return end

    local now = os.time()
    if (now - last_flush_attempt) < opts.retry_interval_seconds then return end
    last_flush_attempt = now

    msg.info(string.format("librefm-scrobbler: retrying %d queued scrobble(s)...", #q))
    while #q > 0 do
        local batch = {}
        for i = 1, math.min(50, #q) do batch[i] = q[i] end

        if submit_batch(batch) then
            for _, t in ipairs(batch) do log_scrobbled(t) end
            local remaining = {}
            for i = #batch + 1, #q do table.insert(remaining, q[i]) end
            q = remaining
            save_queue(q)
        else
            msg.info(string.format("librefm-scrobbler: still failing, %d track(s) remain queued.", #q))
            break
        end
    end
end

-- =====================================================================
-- METADATA / EVENTS
-- =====================================================================
local function get_field(meta, keys)
    for _, k in ipairs(keys) do
        if meta[k] and meta[k] ~= "" then return meta[k] end
    end
    return nil
end

local function on_file_loaded()
    if state.artist and not state.scrobble_triggered then
        check_and_trigger()
    end

    local meta = mp.get_property_native("metadata") or {}
    local artist = get_field(meta, { "artist", "ARTIST", "Artist", "album_artist", "ALBUMARTIST" })
    local title = get_field(meta, { "title", "TITLE", "Title" })
    local album = get_field(meta, { "album", "ALBUM", "Album" }) or ""
    local duration = mp.get_property_number("duration", 0)

    state.artist = nil -- clear until we confirm this file is eligible

    if not artist or not title then
        msg.info("librefm-scrobbler: no artist/title tags - not tracking this file")
        return
    end
    if duration < opts.min_track_duration then
        msg.info(string.format(
            "librefm-scrobbler: track too short (%ds < %ds) - not tracking",
            duration, opts.min_track_duration))
        return
    end

    start_new_play(artist, title, album, duration)
    msg.info(string.format("librefm-scrobbler: track changed: %s - %s (%ds)", artist, title, duration))
end

local function on_tick()
    maybe_flush_queue()
    if not state.artist then return end

    local pos = mp.get_property_number("time-pos")
    if pos == nil then return end

    if state.last_position
        and pos < opts.repeat_reset_threshold
        and state.last_position > opts.repeat_min_prior_position
    then
        check_and_trigger()
        start_new_play(state.artist, state.title, state.album, state.duration)
        msg.info("librefm-scrobbler: repeat play detected: " .. state.artist .. " - " .. state.title)
    end
    state.last_position = pos

    check_and_trigger()
end

if CONFIGURED then
    mp.register_event("file-loaded", on_file_loaded)
    mp.register_event("end-file", function()
        if state.artist and not state.scrobble_triggered then check_and_trigger() end
    end)
    mp.add_periodic_timer(opts.tick_interval, on_tick)
    msg.info("librefm-scrobbler: active for this session")
end

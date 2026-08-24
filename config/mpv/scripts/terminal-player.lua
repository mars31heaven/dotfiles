local utils = require([[mp.utils]])

-- Enforce windowless headless playback
mp.set_property("video", "no")
mp.set_property("osc", "no")
mp.set_property("audio-display", "no")

-- Keep terminal input alive, but force absolute silence on all core modules
mp.set_property("msg-level", "all=no")

local tmp_art = "/tmp/mpv_terminal_cover.jpg"

-- Helper function to wipe the current line and safely print via raw stdout
local function term_write(str)
    io.stdout:write(str)
    io.stdout:flush()
end

mp.register_event("shutdown", function()
    os.remove(tmp_art)
    term_write("\027[?25h\n") -- Restore terminal cursor visibility on exit
end)

local function display_album_art(file_path)
    os.remove(tmp_art)

    local ffmpeg_args = {
        "ffmpeg", "-v", "quiet", "-y",
        "-i", file_path,
        "-an", "-vframes", "1",
        "-f", "image2", tmp_art
    }

    utils.subprocess({args = ffmpeg_args, cancellable = false})

    local file = io.open(tmp_art, "r")
    if file then
        file:close()
        term_write("\n")
        -- Passthrough allows chafa to pipe the binary Sixel data stream straight to foot
        utils.subprocess({
            args = {"chafa", "-f", "sixel", "--size=34x22", tmp_art},
            passthrough = true
        })
        term_write("\n")
    end
end

local function on_file_loaded()
    local path = mp.get_property("path")

    local title  = mp.get_property("metadata/by-key/title") or mp.get_property("media-title") or "Unknown Track"
    local artist = mp.get_property("metadata/by-key/artist") or "Unknown Artist"
    local album  = mp.get_property("metadata/by-key/album") or "Unknown Album"
    local date   = mp.get_property("metadata/by-key/date") or mp.get_property("metadata/by-key/year") or ""

    -- Clear screen, move cursor to top-left, and hide blinking cursor block
    term_write("\027[2J\027[H\027[?25l")

    term_write("TRACK:  " .. title .. "\n")
    term_write("ARTIST: " .. artist .. "\n")
    term_write("ALBUM:  " .. album .. "\n")
    if date ~= "" then
        term_write("YEAR:   " .. date .. "\n")
    end

    if path and not path:find("^http") then
        display_album_art(path)
    end
end

local function on_tick()
    local time_pos = mp.get_property_number("time-pos", 0)
    local duration = mp.get_property_number("duration", 0)

    if duration > 0 then
        local percent = (time_pos / duration) * 100
        local current_str = string.format("%02d:%02d", math.floor(time_pos / 60), math.floor(time_pos % 60))
        local total_str = string.format("%02d:%02d", math.floor(duration / 60), math.floor(duration % 60))

        local bar_length = 30
        local filled_length = math.floor((time_pos / duration) * bar_length)
        local bar = string.rep("━", filled_length) .. string.rep("─", bar_length - filled_length)

        -- Keeps updating progress on a single locked bottom row
        term_write(string.format("\r%s  %s / %s (%d%%)  ", bar, current_str, total_str, math.floor(percent)))
    end
end

-- Fallback explicitly mapping native playlist skips if terminal focus drops them
mp.add_key_binding("RIGHT", "seek_forward", function() mp.command("seek 5") end)
mp.add_key_binding("LEFT", "seek_backward", function() mp.command("seek -5") end)
mp.add_key_binding("SPACE", "toggle_pause", function() mp.command("cycle pause") end)
mp.add_key_binding("q", "quit_player", function() mp.command("quit") end)
mp.add_key_binding(">", "next_track", function() mp.command("playlist-next") end)
mp.add_key_binding("<", "prev_track", function() mp.command("playlist-prev") end)

mp.register_event("file-loaded", on_file_loaded)
mp.add_periodic_timer(0.4, on_tick)

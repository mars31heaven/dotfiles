-- lua/nav.lua — shell shortcuts, `o` and `fcd`, inside Neovim
--
-- Every Neovim *tab* has its own working directory (:tcd). Jump somewhere,
-- pick a file, edit. Open a new tab for another project.
--
--   <leader>j <name>   shortcut -> :tcd -> fzf files     (alias, then `o`)
--   <leader>l <name>   shortcut -> :tcd -> Oil           (alias, which ran `ls`)
--       <name> is typed exactly like in the shell: h d D dfs dx dcf x shr
--       src cf ca M T. It fires as soon as it's unambiguous; for `d`, which is
--       also the start of dx/dfs/dcf, press <CR>. Bare <CR> opens the picker.
--   <leader>cc         fuzzy jump: shortcuts + zoxide frecency <leader>cf         `fcd`: fuzzy pick a directory *under the current one*
--   <leader>cd         :tcd to the current file's directory
--       in directory pickers: <CR> = files there, <C-e> = Oil there
--
--   <leader>f          `o`: fzf files here (PDFs, images, media -> the `open` script)
--   <leader>g / s      live grep / grep word         <leader>o / b  recent / buffers
--   <leader>e  or  -   Oil at the current file       (inside Oil: gx = external open)
--   in the file picker: <C-o> forces external open, <C-g> toggles .gitignore filtering

local M = {}

---------------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------------

-- Same names as shortcutrc. Order is only used for the on-screen hint.
M.shortcuts = {
    { "h", "~" },
    { "d", "~/Documents" },
    { "D", "~/Downloads" },
    { "dfs", "~/.dotfiles" },
    { "dx", "~/.dotfiles/bin" },
    { "dcf", "~/.dotfiles/config" },
    { "x", "~/.local/bin" },
    { "shr", "~/.local/share" },
    { "src", "~/.local/src" },
    { "cf", "~/.config" },
    { "ca", "~/.cache" },
    { "M", "/mnt" },
    { "T", "/tmp" },
    -- { "m", "~/Music" },
    -- { "P", "~/Pictures" },
    -- { "V", "~/Videos" },
}

-- Files with these extensions go to the `open` command (fallback: xdg-open)
-- instead of being edited as text.
M.external_ext = {}
for _, e in ipairs({
    "pdf", "epub", "djvu", "doc", "docx", "odt", "ods", "odp", "xls", "xlsx", "ppt", "pptx",
    "png", "jpg", "jpeg", "gif", "webp", "bmp", "tiff", "heic", "xcf", "psd",
    "mp3", "flac", "ogg", "opus", "m4a", "wav", "mp4", "mkv", "webm", "avi", "mov",
    "zip", "7z", "rar", "tar", "gz", "xz", "iso",
}) do
    M.external_ext[e] = true
end

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function fzf()
    return require("fzf-lua")
end

local function norm(path)
    return vim.fs.normalize(path) -- expands ~ and $VARS, drops trailing /
end

local function lookup(name)
    for _, s in ipairs(M.shortcuts) do
        if s[1] == name then return s[2] end
    end
end

local function with_prefix(prefix)
    local out = {}
    for _, s in ipairs(M.shortcuts) do
        if vim.startswith(s[1], prefix) then table.insert(out, s[1]) end
    end
    return out
end

local function is_external(path)
    local ext = path:match("%.([^./]+)$")
    return ext ~= nil and M.external_ext[ext:lower()] == true
end

local function open_external(path)
    local cmd = vim.fn.executable("open") == 1 and "open" or "xdg-open"
    vim.fn.jobstart({ cmd, path }, { detach = true })
end

local dir_preview = vim.fn.executable("eza") == 1
        and "eza -a --group-directories-first --color=always {}"
    or "ls -1A --color=always {}"

--- Set the tab-local working directory. Returns true on success.
function M.cd(dir)
    dir = norm(dir)
    if vim.fn.isdirectory(dir) == 0 then
        vim.notify("Not a directory: " .. dir, vim.log.levels.WARN)
        return false
    end
    vim.cmd("tcd " .. vim.fn.fnameescape(dir))
    return true
end

function M.oil(dir)
    require("oil").open(dir or vim.fn.getcwd())
end

---------------------------------------------------------------------------
-- `o`: file picker
---------------------------------------------------------------------------

--- fzf over files under `dir` (default: cwd).
function M.files(dir)
    local f = fzf()
    local function resolve(entry, opts)
        return require("fzf-lua.path").entry_to_file(entry, opts).path
    end
    f.files({
        cwd = dir or vim.fn.getcwd(),
        actions = {
            ["default"] = function(selected, opts)
                local text = {}
                for _, entry in ipairs(selected) do
                    local path = resolve(entry, opts)
                    if is_external(path) then
                        open_external(path)
                    else
                        table.insert(text, entry)
                    end
                end
                if #text > 0 then f.actions.file_edit_or_qf(text, opts) end
            end,
            -- fzf-lua's default is <A-i>, which tmux would swallow (Alt bindings)
            ["ctrl-g"] = { fn = f.actions.toggle_ignore, reuse = true, header = false },
            ["ctrl-o"] = function(selected, opts)
                for _, entry in ipairs(selected) do
                    open_external(resolve(entry, opts))
                end
            end,
        },
    })
end

---------------------------------------------------------------------------
-- Directory pickers
---------------------------------------------------------------------------

-- `root` makes relative picker entries absolute.
local function dir_actions(root)
    local function after_pick(open)
        return function(selected)
            local dir = selected and selected[1]
            if not dir then return end
            if not vim.startswith(dir, "/") and not vim.startswith(dir, "~") then
                dir = root .. "/" .. dir
            end
            if M.cd(dir) then
                -- schedule: let fzf-lua finish closing its window first
                vim.schedule(function() open(vim.fn.getcwd()) end)
            end
        end
    end
    return {
        ["default"] = after_pick(M.files),
        ["ctrl-e"] = after_pick(M.oil),
    }
end

--- Shortcuts first, then zoxide's frecency list.
function M.jump()
    local list, seen = {}, {}
    local function add(path)
        path = norm(path)
        if not seen[path] and vim.fn.isdirectory(path) == 1 then
            seen[path] = true
            table.insert(list, path)
        end
    end

    for _, s in ipairs(M.shortcuts) do add(s[2]) end
    if vim.fn.executable("zoxide") == 1 then
        for _, p in ipairs(vim.fn.systemlist({ "zoxide", "query", "--list" })) do
            add(p)
        end
    end

    fzf().fzf_exec(list, {
        prompt = "Jump> ",
        actions = dir_actions("/"),
        preview = dir_preview,
    })
end

--- `fcd`: every directory under `root` (default: cwd), hidden and ignored included.
function M.find_dir(root)
    root = root or vim.fn.getcwd()
    fzf().fzf_exec("fd --type d --hidden --no-ignore --exclude .git", {
        cwd = root,
        prompt = "Dirs> ",
        actions = dir_actions(root),
        preview = dir_preview,
    })
end

---------------------------------------------------------------------------
-- Typing a shortcut name, like in the shell
---------------------------------------------------------------------------

--- Read a shortcut name key by key, jump, then call `open(dir)`.
function M.shortcut(open)
    open = open or M.files
    local buf, target, picker, warn = "", nil, false, nil

    while true do
        vim.api.nvim_echo(
            { { "jump> " .. buf .. "    " .. table.concat(with_prefix(buf), "  ") } },
            false, {}
        )
        vim.cmd("redraw")

        local ok, ch = pcall(vim.fn.getcharstr)
        if not ok or ch == "\27" or ch == "\3" then -- Esc / Ctrl-C
            break
        elseif ch == "\r" then
            if buf == "" then
                picker = true
            elseif lookup(buf) then
                target = lookup(buf)
            else
                warn = "No shortcut: " .. buf
            end
            break
        elseif ch == "\8" or ch == "\127" or ch == vim.keycode("<BS>") then
            buf = buf:sub(1, -2)
        else
            buf = buf .. ch
            local exact = lookup(buf)
            local longer = #with_prefix(buf) - (exact and 1 or 0) > 0
            if exact and not longer then
                target = exact
                break
            elseif not exact and not longer then
                warn = "No shortcut: " .. buf
                break
            end
        end
    end

    vim.cmd("echo ''")
    vim.cmd("redraw")

    if warn then vim.notify(warn, vim.log.levels.WARN) end
    if picker then
        M.jump()
    elseif target and M.cd(target) then
        open(vim.fn.getcwd())
    end
end

---------------------------------------------------------------------------
-- New file
---------------------------------------------------------------------------

--- Choose a directory starting from home, then create or open a file there.
function M.new_file()
    local home = vim.fn.expand("~")
    local dirs = { home }

    for _, dir in ipairs(vim.fn.systemlist({
        "fd",
        "--type", "d",
        "--hidden",
        "--no-ignore",
        "--exclude", ".git",
        ".",
        home,
    })) do
        table.insert(dirs, dir)
    end

    fzf().fzf_exec(dirs, {
        prompt = "New file in> ",
        preview = dir_preview,
        actions = {
            ["default"] = function(selected)
                local dir = selected and selected[1]
                if not dir then return end

                vim.ui.input({
                    prompt = "Filename: ",
                    default = "",
                }, function(name)
                    if not name or name == "" then return end

                    local path = vim.fs.joinpath(dir, name)

                    if M.cd(dir) then
                        vim.cmd("edit " .. vim.fn.fnameescape(path))
                    end
                end)
            end,
        },
    })
end

---------------------------------------------------------------------------
-- Mappings
---------------------------------------------------------------------------

local map = vim.keymap.set

map("n", "<leader>j", function() M.shortcut(M.files) end, { desc = "Shortcut -> files" })
map("n", "<leader>l", function() M.shortcut(M.oil) end, { desc = "Shortcut -> file manager" })

map("n", "<leader>cc", M.jump, { desc = "Jump (shortcuts + zoxide)" })
map("n", "<leader>cf", function() M.find_dir() end, { desc = "fcd: directory under cwd" })
map("n", "<leader>cd", function()
    local dir = vim.bo.filetype == "oil" and require("oil").get_current_dir()
        or vim.fn.expand("%:p:h")
    if dir and M.cd(dir) then
        vim.notify("tcd " .. vim.fn.fnamemodify(dir, ":~"))
    end
end, { desc = "tcd to this file's directory" })

map("n", "<leader>f", function() M.files() end, { desc = "Find files" })
map("n", "<leader>g", function() fzf().live_grep() end, { desc = "Live grep" })
map("n", "<leader>s", function() fzf().grep_cword() end, { desc = "Grep word" })
map("n", "<leader>o", function() fzf().oldfiles() end, { desc = "Recent files" })
map("n", "<leader>b", function() fzf().buffers() end, { desc = "Buffers" })

map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "File manager" })
map("n", "-", "<cmd>Oil<CR>", { desc = "File manager (parent dir)" })

map("n", "<leader>n", M.new_file, {
    desc = "New file from home",
})

---------------------------------------------------------------------------
-- Keep zoxide in sync, so directories visited from Neovim also rank in
-- the shell's `z` (and vice versa).
---------------------------------------------------------------------------

vim.api.nvim_create_autocmd("DirChanged", {
    group = vim.api.nvim_create_augroup("nav_zoxide", { clear = true }),
    callback = function()
        if vim.fn.executable("zoxide") == 1 then
            vim.fn.jobstart({ "zoxide", "add", vim.v.event.cwd })
        end
    end,
})

return M

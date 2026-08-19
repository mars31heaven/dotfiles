-- ~/.config/nvim/init.lua

-----------------------------------------------------------
-- General
-----------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.background = "dark"
vim.opt.termguicolors = true

vim.opt.history = 1000
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 5

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.confirm = true

vim.opt.wildmode = { "longest", "list" }

vim.opt.laststatus = 3

vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

vim.opt.showmode = false
vim.opt.showcmd = false

vim.opt.updatetime = 250
vim.opt.timeoutlen = 500

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"

vim.opt.swapfile = false

-----------------------------------------------------------
-- Appearance
-----------------------------------------------------------

local bg = "#313131"
local fg = "#E1E1DB"
local muted = "#d8cfd8"
local accent = "#de7484"
local urgent = "#db3d3f"

vim.cmd("highlight clear")
vim.cmd("set t_Co=256")

vim.api.nvim_set_hl(0, "Normal", {
    fg = fg,
    bg = bg,
})

vim.api.nvim_set_hl(0, "NormalFloat", {
    fg = fg,
    bg = bg,
})

vim.api.nvim_set_hl(0, "CursorLine", {
    bg = "#383838",
})

vim.api.nvim_set_hl(0, "CursorLineNr", {
    fg = accent,
    bold = true,
})

vim.api.nvim_set_hl(0, "LineNr", {
    fg = muted,
})

vim.api.nvim_set_hl(0, "Visual", {
    bg = "#4a4a4a",
})

vim.api.nvim_set_hl(0, "Search", {
    fg = bg,
    bg = accent,
})

vim.api.nvim_set_hl(0, "IncSearch", {
    fg = bg,
    bg = accent,
})

vim.api.nvim_set_hl(0, "StatusLine", {
    fg = fg,
    bg = "#383838",
})

vim.api.nvim_set_hl(0, "StatusLineNC", {
    fg = muted,
    bg = "#383838",
})

vim.api.nvim_set_hl(0, "WinSeparator", {
    fg = "#555555",
    bg = bg,
})

vim.api.nvim_set_hl(0, "Directory", {
    fg = accent,
})

vim.api.nvim_set_hl(0, "ErrorMsg", {
    fg = urgent,
    bold = true,
})

vim.api.nvim_set_hl(0, "WarningMsg", {
    fg = accent,
})

-----------------------------------------------------------
-- Minimal statusline
-----------------------------------------------------------

vim.opt.statusline = table.concat({
    " ",
    "%f",
    " %m",
    "%=",
    "%y",
    "  ",
    "%l:%c",
    " ",
})

-----------------------------------------------------------
-- Leader mappings
-----------------------------------------------------------

local map = vim.keymap.set

-- Save / quit
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })

-- Reload configuration
map("n", "<leader>r", "<cmd>source $MYVIMRC<CR>", {
    desc = "Reload config",
})

-----------------------------------------------------------
-- Buffers
-----------------------------------------------------------

map("n", "<leader>]", "<cmd>bnext<CR>", {
    desc = "Next buffer",
})

map("n", "<leader>[", "<cmd>bprevious<CR>", {
    desc = "Previous buffer",
})

map("n", "<leader>b", "<cmd>ls<CR>", {
    desc = "List buffers",
})

-----------------------------------------------------------
-- Splits
-----------------------------------------------------------

map("n", "<leader>n", "<cmd>new<CR>", {
    desc = "Horizontal split",
})

map("n", "<leader>v", "<cmd>vnew<CR>", {
    desc = "Vertical split",
})

map("n", "<C-h>", "<C-w>h", {
    desc = "Move left",
})

map("n", "<C-j>", "<C-w>j", {
    desc = "Move down",
})

map("n", "<C-k>", "<C-w>k", {
    desc = "Move up",
})

map("n", "<C-l>", "<C-w>l", {
    desc = "Move right",
})

map("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")
map("n", "<C-Up>", "<cmd>resize +2<CR>")
map("n", "<C-Down>", "<cmd>resize -2<CR>")

-----------------------------------------------------------
-- Tabs
-----------------------------------------------------------

map("n", "<leader>t", "<cmd>tabnew<CR>", {
    desc = "New tab",
})

map("n", "<leader>J", "<cmd>tabnext<CR>", {
    desc = "Next tab",
})

map("n", "<leader>K", "<cmd>tabprevious<CR>", {
    desc = "Previous tab",
})

map("n", "<leader>d", "<cmd>tabclose<CR>", {
    desc = "Close tab",
})

-----------------------------------------------------------
-- File explorer
-----------------------------------------------------------

map("n", "<leader>e", "<cmd>Explore<CR>", {
    desc = "File explorer",
})

-----------------------------------------------------------
-- Search
-----------------------------------------------------------

map("n", "<leader>h", "<cmd>nohlsearch<CR>", {
    desc = "Clear search",
})

map("n", "<leader>s", "<cmd>vimgrep /<C-r><C-w>/gj **/*<CR>", {
    desc = "Search word",
})

-----------------------------------------------------------
-- Spell checking
-----------------------------------------------------------

map("n", "<leader>en", function()
    vim.opt_local.spell = not vim.opt_local.spell:get()
    vim.opt_local.spelllang = "en_us"
end, {
    desc = "English spellcheck",
})

map("n", "<leader>pt", function()
    vim.opt_local.spell = not vim.opt_local.spell:get()
    vim.opt_local.spelllang = "pt_br"
end, {
    desc = "Portuguese spellcheck",
})

-----------------------------------------------------------
-- Date/time
-----------------------------------------------------------

local function insert_datetime()
    vim.api.nvim_put(
        { os.date("%Y-%m-%d %H:%M") },
        "c",
        true,
        true
    )
end

map("n", "<F5>", insert_datetime)
map("i", "<F5>", function()
    vim.api.nvim_put(
        { os.date("%Y-%m-%d %H:%M") },
        "c",
        true,
        true
    )
end)

-----------------------------------------------------------
-- Better blank lines
-----------------------------------------------------------

map("n", "oo", "m`o<Esc>``", {
    desc = "Blank line below",
})

map("n", "OO", "m`O<Esc>``", {
    desc = "Blank line above",
})

-----------------------------------------------------------
-- File behavior
-----------------------------------------------------------

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local line_count = vim.api.nvim_buf_line_count(0)

        if mark[1] > 1 and mark[1] <= line_count then
            vim.cmd('normal! g`"zz')
        end
    end,
})

-- Remove automatic comment continuation.
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        vim.opt_local.formatoptions:remove({
            "c",
            "r",
            "o",
        })
    end,
})

-- Remove trailing whitespace on save.
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        local view = vim.fn.winsaveview()

        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

-----------------------------------------------------------
-- Markdown
-----------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "markdown",
        "text",
        "gitcommit",
    },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = false
    end,
})

-----------------------------------------------------------
-- Interface
-----------------------------------------------------------

vim.opt.ruler = true
vim.opt.title = true
vim.opt.titlestring = "nvim - %t"

-----------------------------------------------------------
-- Miscellaneous
-----------------------------------------------------------

vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

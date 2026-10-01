-- lua/plugins.lua — plugin manager bootstrap + specs

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

    -- Notes. vim.g.vimwiki_* are set in init.lua before this file runs.
    { "vimwiki/vimwiki", lazy = false },

    -- Fuzzy finder: files, grep, buffers, recent files, ui.select
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        opts = {
            winopts = {
                height = 0.85,
                width = 0.85,
                preview = { layout = "flex", flip_columns = 140 },
            },
            -- like the `o` (find) and `fd --unrestricted`: ignore nothing but .git.
            -- <C-g> inside the file picker toggles .gitignore filtering back on.
            files = { hidden = true, follow = true, no_ignore = true },
            grep = { hidden = true, no_ignore = true },
        },
        config = function(_, opts)
            local fzf = require("fzf-lua")
            fzf.setup(opts)
            fzf.register_ui_select()
        end,
    },

    -- File manager: edit the filesystem like a buffer.
    --   -  parent dir    _  cwd    g~  :tcd here    `  :cd here    g?  help
    {
        "stevearc/oil.nvim",
        lazy = false, -- needed so `nvim some/dir` opens Oil
        opts = {
            default_file_explorer = true,
            columns = {}, -- names only; use { "icon" } with a Nerd Font + mini.icons
            view_options = { show_hidden = true },
            skip_confirm_for_simple_edits = true,
            keymaps = {
                -- Oil's defaults steal <C-h>/<C-l>, which are pane navigation.
                ["<C-h>"] = false,
                ["<C-l>"] = false,
                ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
                ["<C-v>"] = { "actions.select", opts = { vertical = true } },
                ["<C-r>"] = "actions.refresh",
                ["q"] = "actions.close",
                -- fzf inside the directory Oil is showing
                ["<leader>f"] = {
                    desc = "Find files in this directory",
                    callback = function()
                        require("nav").files(require("oil").get_current_dir())
                    end,
                },
            },
        },
    },

{
  "maelwalser/oil-copy.nvim",
  dependencies = { "stevearc/oil.nvim" },
  opts = {
    keymap = "<leader>' '"
  },
  config = function()
    require("oil-copy").setup()
  end,
}

}, {
    checker = { enabled = false },
    change_detection = { notify = false },
})

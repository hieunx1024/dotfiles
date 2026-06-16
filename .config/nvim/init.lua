-- pull lazy vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- install plugins and options
require("vim-options")
require("vim-helpers")
require("help-floating")
require("floating-term")
require("ws").setup()
require("lazy").setup({
    { import = "plugins.ui" },
    { import = "plugins.lsp" },
    { import = "plugins.languages" },
    { import = "plugins.tools" },
    { import = "plugins.utils" },
    { import = "plugins.platform" },
})
require("snipets")

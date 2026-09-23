return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local status_ok, config = pcall(require, "nvim-treesitter.configs")
        if not status_ok then
            return
        end
        config.setup({
            -- auto install
            auto_install = true,
            -- add language you want to highlight in code
            ensure_installed = {
                "c",
                "lua",
                "vim",
                "javascript",
                "typescript",
                "tsx",
                "html",
                "go",
                "gomod",
                "java",
                "json",
                "zig",
                "http",
                "rust",
                "markdown",
                "markdown_inline",
            },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}

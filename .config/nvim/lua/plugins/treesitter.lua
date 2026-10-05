-- Fix compatibility between Neovim 0.12+ (which passes TSNode[] in query directives)
-- and legacy treesitter queries/predicates expecting a single TSNode.
local function patch_treesitter_api()
    if not vim.treesitter then
        return
    end

    local orig_get_range = vim.treesitter.get_range
    if orig_get_range then
        vim.treesitter.get_range = function(node, source, metadata)
            if type(node) == "table" and not node.range and node[1] and node[1].range then
                node = node[1]
            end
            return orig_get_range(node, source, metadata)
        end
    end

    local orig_get_node_text = vim.treesitter.get_node_text
    if orig_get_node_text then
        vim.treesitter.get_node_text = function(node, source, opts)
            if type(node) == "table" and not node.range and node[1] and (node[1].range or node[1].start) then
                node = node[1]
            end
            return orig_get_node_text(node, source, opts)
        end
    end
end

patch_treesitter_api()

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    priority = 1000,
    init = patch_treesitter_api,
    build = ":TSUpdate",
    config = function()
        patch_treesitter_api()
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

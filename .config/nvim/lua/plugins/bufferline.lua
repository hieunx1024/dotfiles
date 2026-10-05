return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers", -- hiển thị các file đang mở (buffers)
                separator_style = "thin",
                numbers = "none",
                indicator = {
                    style = "none",
                },
                always_show_bufferline = true,
                show_buffer_close_icons = true,
                show_close_icon = false,
                color_icons = false,
                diagnostics = "nvim_lsp", -- hiển thị trực tiếp số lỗi/cảnh báo LSP trên từng tab!
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    local icon = level:match("error") and " " or " "
                    return " " .. icon .. count
                end,
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        text_align = "left",
                        separator = true,
                    },
                },
            },
            highlights = {
                fill = { bg = "#181818" },
                background = { fg = "#73726c", bg = "#181818" },
                buffer_visible = { fg = "#9c9a92", bg = "#181818" },
                buffer_selected = { fg = "#dedcd1", bg = "#2d2d2d", bold = true, italic = false },
                close_button = { fg = "#73726c", bg = "#181818" },
                close_button_visible = { fg = "#9c9a92", bg = "#181818" },
                close_button_selected = { fg = "#c2c0b6", bg = "#2d2d2d" },
                separator = { fg = "#181818", bg = "#181818" },
                separator_visible = { fg = "#181818", bg = "#181818" },
                separator_selected = { fg = "#181818", bg = "#2d2d2d" },
                indicator_selected = { fg = "#2d2d2d", bg = "#2d2d2d" },
                modified = { fg = "#9c9a92", bg = "#181818" },
                modified_visible = { fg = "#c2c0b6", bg = "#181818" },
                modified_selected = { fg = "#dedcd1", bg = "#2d2d2d" },
                diagnostic = { fg = "#73726c", bg = "#181818" },
                diagnostic_visible = { fg = "#9c9a92", bg = "#181818" },
                diagnostic_selected = { fg = "#c2c0b6", bg = "#2d2d2d", bold = true },
            },
        })
    end,
}

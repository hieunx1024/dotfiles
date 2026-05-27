return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers", -- hiển thị các file đang mở (buffers)
                separator_style = "slant", -- viền chéo nghiêng cực kỳ hiện đại và cao cấp
                numbers = "ordinal", -- hiển thị số thứ tự 1, 2, 3... để dễ nhảy trực tiếp
                indicator = {
                    style = "icon",
                    icon = "▎",
                },
                always_show_bufferline = true,
                show_buffer_close_icons = true,
                show_close_icon = false,
                color_icons = true,
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
        })
    end,
}

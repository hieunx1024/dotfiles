return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
        heading = {
            sign = true,
            icons = { "┃ ", "┃ ", "┃ ", "┃ ", "┃ ", "┃ " },
        },
        code = {
            sign = true,
            style = "full",
            position = "left",
            width = "block",
            left_pad = 2,
            right_pad = 4,
            border = "thin",
        },
        bullet = {
            icons = { "●", "○", "◆", "◇" },
        },
        checkbox = {
            unchecked = { icon = "󰄱 " },
            checked = { icon = "󰄵 " },
        },
        pipe_table = {
            style = "full",
        },
    },
}

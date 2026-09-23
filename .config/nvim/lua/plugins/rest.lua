return {
    "mistweaverco/kulala.nvim",
    tag = "v4.1.0",
    ft = { "http", "rest" },
    keys = {
        {
            "<leader>Kt",
            function()
                require("kulala").run()
            end,
            desc = "Send request",
        },
        {
            "<leader>Ka",
            function()
                require("kulala").run_all()
            end,
            desc = "Send all requests",
        },
        {
            "<leader>Ko",
            function()
                require("kulala").scratchpad()
            end,
            desc = "Open scratchpad",
        },
    },
}

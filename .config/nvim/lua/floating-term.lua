local state = { floating = { buf = -1, win = -1 } }

local graphite_terminal_colors = {
    "#2d2d2d", "#dd5353", "#65bb30", "#e5b567",
    "#2c84db", "#9b87f5", "#4fb3b3", "#c2c0b6",
    "#73726c", "#fe8181", "#8fd15f", "#f0c987",
    "#74abe2", "#b8a9f8", "#7fcccc", "#faf9f5",
}

local function apply_graphite_terminal_colors()
    for index, color in ipairs(graphite_terminal_colors) do
        vim.g["terminal_color_" .. (index - 1)] = color
    end
end

local function focus_floating_terminal()
    -- Đợi mapping/autocmd mở cửa sổ chạy xong rồi mới giành focus và vào Terminal mode.
    vim.schedule(function()
        if not vim.api.nvim_win_is_valid(state.floating.win) then
            return
        end

        vim.api.nvim_set_current_win(state.floating.win)
        vim.cmd.startinsert()
    end)
end

local function create_floating_window(opts)
    opts = opts or {}
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
    end

    local config = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded"
    }
    vim.api.nvim_set_hl(0, "MyFloatingWindow", { bg = "#1c1c1c", fg = "#dedcd1" })
    vim.api.nvim_set_hl(0, "MyFloatingBorder", { bg = "#1c1c1c", fg = "#73726c" })
    local win = vim.api.nvim_open_win(buf, true, config)
    vim.api.nvim_set_option_value(
        "winhighlight",
        "Normal:MyFloatingWindow,NormalFloat:MyFloatingWindow,FloatBorder:MyFloatingBorder",
        { win = win }
    )
    return { buf = buf, win = win }
end

local toggle_term = function()
    if not vim.api.nvim_win_is_valid(state.floating.win) then
        state.floating = create_floating_window { buf = state.floating.buf }
        if vim.bo[state.floating.buf].buftype ~= "terminal" then
            apply_graphite_terminal_colors()
            vim.cmd.terminal()
            vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {
                buffer = state.floating.buf,
                silent = true,
                desc = "Exit terminal mode",
            })
        end
        focus_floating_terminal()
    else
        vim.api.nvim_win_hide(state.floating.win)
    end
end

vim.api.nvim_create_user_command("FTerm", toggle_term, {})
vim.keymap.set("n", "<leader>T", toggle_term, { desc = "Toggle floating terminal" })
vim.keymap.set("t", "<C-t>", toggle_term, { desc = "Toggle floating terminal" })

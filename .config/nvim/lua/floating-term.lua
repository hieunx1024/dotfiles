local state = { floating = { buf = -1, win = -1 } }
local function create_floating_window(opts)
    opts = opts or {}
    local width = math.floor(vim.o.columns * 0.4)
    local height = math.floor(vim.o.lines * 0.4)

    local row = 0
    local col = vim.o.columns - width

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
    
    local win = vim.api.nvim_open_win(buf, true, config)
    
    -- Enable transparency blend (15% transparent)
    vim.wo[win].winblend = 15
    
    return { buf = buf, win = win }
end

local toggle_term = function()
    if not vim.api.nvim_win_is_valid(state.floating.win) then
        state.floating = create_floating_window { buf = state.floating.buf }
        local current_buf = state.floating.buf
        
        if vim.bo[current_buf].buftype ~= "terminal" then
            -- Run the default shell inside the current scratch buffer
            vim.fn.termopen(vim.o.shell)

            -- Auto-close window and clean up buffer when terminal exits (e.g. typing 'exit')
            vim.api.nvim_create_autocmd("TermClose", {
                buffer = current_buf,
                callback = function()
                    vim.schedule(function()
                        if vim.api.nvim_win_is_valid(state.floating.win) then
                            vim.api.nvim_win_close(state.floating.win, true)
                        end
                        if vim.api.nvim_buf_is_valid(current_buf) then
                            vim.api.nvim_buf_delete(current_buf, { force = true })
                        end
                        state.floating = { buf = -1, win = -1 }
                    end)
                end,
                once = true,
            })

            -- Auto-enter insert mode when focusing the terminal window
            vim.api.nvim_create_autocmd("BufEnter", {
                buffer = current_buf,
                callback = function()
                    vim.cmd("startinsert")
                end,
            })
        end
        
        -- Automatically enter insert mode when opened
        vim.cmd("startinsert")
    else
        vim.api.nvim_win_hide(state.floating.win)
    end
end

vim.api.nvim_create_user_command("FTerm", toggle_term, {})
vim.keymap.set({ "n", "t" }, "<leader>T", toggle_term)

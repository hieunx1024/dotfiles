-- all vim helper functions here

vim.keymap.set("n", "<leader>ce", function()
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    if #diagnostics > 0 then
        local message = diagnostics[1].message
        vim.fn.setreg("+", message)
        print("Copied diagnostic: " .. message)
    else
        print("No diagnostic at cursor")
    end
end, { noremap = true, silent = true })

-- go to errors in a file :/
vim.keymap.set("n", "<leader>ne", function() vim.diagnostic.jump({ count = 1 }) end) -- next err
vim.keymap.set("n", "<leader>pe", function() vim.diagnostic.jump({ count = -1 }) end) -- previous err
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
-- copy current file path (absolute) into clipboard
vim.keymap.set("n", "<leader>cp", function()
    local filepath = vim.fn.expand("%:p")
    vim.fn.setreg("+", filepath) -- Copy to system clipboard
    vim.notify("Copied: " .. filepath, vim.log.levels.INFO)
end, { desc = "Copy absolute path to clipboard" })

-- open the current file in browser
vim.keymap.set("n", "<leader>ob", function()
    local file_path = vim.fn.expand("%:p")
    if file_path ~= "" then
        local cmd
        if vim.fn.has("mac") == 1 then
            local firefox_installed = vim.fn.system("which /Applications/Firefox.app/Contents/MacOS/firefox")
            if firefox_installed == "" then
                cmd = "open -a 'Google Chrome' " .. file_path
            else
                cmd = "open -a 'Firefox' " .. file_path
            end
        else
            -- Linux: prefer firefox, fallback to xdg-open
            local firefox_path = vim.fn.system("which firefox"):gsub("\n", "")
            if firefox_path ~= "" then
                cmd = "firefox " .. file_path
            else
                cmd = "xdg-open " .. file_path
            end
        end
        os.execute(cmd .. " &")
    else
        print("No file to open")
    end
end, { desc = "Open current file in browser" })

-- set language based on vim mode
-- requires macism https://github.com/laishulu/macism
-- recommend installing it by brew
local sysname = vim.loop.os_uname().sysname
local is_mac = sysname == "Darwin"
local is_linux = sysname == "Linux"

if is_mac then
    local english_layout = "com.apple.keylayout.ABC"
    local last_insert_layout = english_layout

    local function get_current_layout()
        local f = io.popen("macism")
        local layout = nil
        if f ~= nil then
            layout = f:read("*all"):gsub("\n", "")
            f:close()
        end
        print(layout)
        return layout
    end

    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
            last_insert_layout = get_current_layout()
            os.execute("macism " .. english_layout)
        end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
            os.execute("macism " .. last_insert_layout)
        end,
    })

    vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
            if vim.fn.mode() == "i" then
                os.execute("macism " .. last_insert_layout)
            else
                os.execute("macism " .. english_layout)
            end
        end,
    })
elseif is_linux then
    local last_layout = "keyboard-us" -- English is default

    local function get_fcitx_layout()
        local f = io.popen("fcitx5-remote -n")
        if f ~= nil then
            local result = f:read("*all")
            f:close()
            if result then
                return result:gsub("%s+", "")
            end
        end
        return "keyboard-us" -- fallback English
    end

    local function set_fcitx_layout(layout)
        os.execute("fcitx5-remote -s " .. layout)
    end

    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
            last_layout = get_fcitx_layout()
            set_fcitx_layout("keyboard-us") -- change to English
        end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
            set_fcitx_layout(last_layout)
        end,
    })

    vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
            if vim.fn.mode() == "i" then
                set_fcitx_layout(last_layout)
            else
                set_fcitx_layout("keyboard-us")
            end
        end,
    })
end

-- Show folder/dir structure
local tree_win = nil
local tree_buf = nil

vim.api.nvim_create_user_command("ShowTree", function()
    -- Nếu cửa sổ đang mở thì đóng lại (Toggle)
    if tree_win and vim.api.nvim_win_is_valid(tree_win) then
        vim.api.nvim_win_close(tree_win, true)
        tree_win = nil
        return
    end

    tree_buf = vim.api.nvim_create_buf(false, true)
    local editor_width = vim.o.columns
    local editor_height = vim.o.lines
    local width = math.floor(editor_width * 0.6)
    local height = math.floor(editor_height * 0.9)

    local row = math.floor((editor_height - height) / 2)
    local col = math.floor((editor_width - width) / 2)
    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "rounded",
        style = "minimal",
    }

    tree_win = vim.api.nvim_open_win(tree_buf, true, opts)
    
    -- Cài đặt phím tắt 'q' để thoát nhanh pop-up
    vim.keymap.set("n", "q", function()
        if tree_win and vim.api.nvim_win_is_valid(tree_win) then
            vim.api.nvim_win_close(tree_win, true)
            tree_win = nil
        end
    end, { buffer = tree_buf, silent = true })

    if vim.fn.executable("tree") == 0 then
        vim.api.nvim_buf_set_lines(tree_buf, 0, -1, false, {
            "Lỗi: Không tìm thấy lệnh 'tree' trên hệ thống.",
            "Vui lòng cài đặt bằng lệnh: sudo pacman -S tree"
        })
        return
    end

    -- Xoá buffer trước khi nạp data mới để tránh dính chữ
    vim.api.nvim_buf_set_lines(tree_buf, 0, -1, false, {})

    local job_id = vim.fn.jobstart("tree -L 4", {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data and vim.api.nvim_buf_is_valid(tree_buf) then
                for _, line in ipairs(data) do
                    vim.api.nvim_buf_set_lines(tree_buf, -1, -1, true, { line })
                end
            end
        end,
    })
end, {})

vim.keymap.set("n", "<leader>vt", ":ShowTree<CR>", { desc = "Show directory tree in floating window" })

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
vim.keymap.set("n", "<leader>ne", vim.diagnostic.goto_next) -- next err
vim.keymap.set("n", "<leader>pe", vim.diagnostic.goto_prev) -- previous err
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

    -- vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
    -- 	callback = function()
    -- 		os.execute("macism " .. english_layout)
    -- 	end,
    -- })

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
    local last_layout = nil

    local function get_ime()
        -- Try ibus first
        local f_ibus = io.popen("ibus engine 2>/dev/null")
        if f_ibus then
            local res = f_ibus:read("*all")
            f_ibus:close()
            if res and res:match("%S+") then
                return "ibus", res:gsub("%s+", "")
            end
        end

        -- Try fcitx5
        local f_fcitx = io.popen("fcitx5-remote -n 2>/dev/null")
        if f_fcitx then
            local res = f_fcitx:read("*all")
            f_fcitx:close()
            if res and res:match("%S+") then
                return "fcitx5", res:gsub("%s+", "")
            end
        end

        return nil, nil
    end

    local function set_ime(ime_type, layout)
        if ime_type == "ibus" then
            os.execute("ibus engine " .. layout .. " >/dev/null 2>&1")
        elseif ime_type == "fcitx5" then
            os.execute("fcitx5-remote -s " .. layout .. " >/dev/null 2>&1")
        end
    end

    local function get_english_layout(ime_type, current)
        if ime_type == "ibus" then
            if current == "Bamboo" then
                return "BambooUs"
            elseif current:find("xkb:us") or current:find("Us") then
                return current
            else
                return "BambooUs"
            end
        elseif ime_type == "fcitx5" then
            return "keyboard-us"
        end
        return "keyboard-us"
    end

    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
            local ime_type, current = get_ime()
            if ime_type and current then
                local english = get_english_layout(ime_type, current)
                if current ~= english then
                    last_layout = { type = ime_type, layout = current }
                    set_ime(ime_type, english)
                end
            end
        end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
            if last_layout and last_layout.type then
                set_ime(last_layout.type, last_layout.layout)
            end
        end,
    })

    vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
            local ime_type, current = get_ime()
            if ime_type then
                if vim.fn.mode() == "i" then
                    if last_layout and last_layout.type == ime_type then
                        set_ime(last_layout.type, last_layout.layout)
                    end
                else
                    local english = get_english_layout(ime_type, current or "")
                    set_ime(ime_type, english)
                end
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

-- Open Keybindings documentation in a floating window
local help_win = nil
local help_buf = nil

vim.api.nvim_create_user_command("HelpKeys", function()
    if help_win and vim.api.nvim_win_is_valid(help_win) then
        vim.api.nvim_win_close(help_win, true)
        help_win = nil
        return
    end

    local keybindings_path = vim.fn.expand("~/.config/nvim/KEYBINDINGS.md")
    help_buf = vim.api.nvim_create_buf(false, true)

    if vim.fn.filereadable(keybindings_path) == 1 then
        local lines = vim.fn.readfile(keybindings_path)
        vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, lines)
    else
        vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, { "# Keybindings file not found" })
    end

    vim.api.nvim_set_option_value("filetype", "markdown", { buf = help_buf })
    vim.api.nvim_set_option_value("modifiable", false, { buf = help_buf })

    local editor_width = vim.o.columns
    local editor_height = vim.o.lines
    local width = math.floor(editor_width * 0.85)
    local height = math.floor(editor_height * 0.85)
    local col = math.floor((editor_width - width) / 2)
    local row = math.floor((editor_height - height) / 2)

    help_win = vim.api.nvim_open_win(help_buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
        title = " ⌨️ Neovim Keybindings Cheatsheet (Press q to close) ",
        title_pos = "center",
    })

    vim.keymap.set("n", "q", function()
        if help_win and vim.api.nvim_win_is_valid(help_win) then
            vim.api.nvim_win_close(help_win, true)
            help_win = nil
        end
    end, { buffer = help_buf, silent = true })
end, {})

vim.keymap.set("n", "<leader>?", ":HelpKeys<CR>", { desc = "Show Neovim Keybindings cheatsheet" })


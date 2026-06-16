vim.g.mapleader = " "

-- --- Editor Options ---
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.colorcolumn = "94"

vim.opt.clipboard = "unnamedplus"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "auto"
vim.opt.updatetime = 250
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- --- Highlight Styles ---
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "white" })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#ead84e" })

-- --- LSP Notification Filter ---
-- Filter out repetitive offset_encoding warnings from LSP clients
local notify_original = vim.notify
vim.notify = function(msg, ...)
    if
        msg
        and (
            msg:match("position_encoding param is required")
            or msg:match("Defaulting to position encoding of the first client")
            or msg:match("multiple different client offset_encodings")
        )
    then
        return
    end
    return notify_original(msg, ...)
end

-- --- Keymaps ---
-- Move selected lines in Visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Paste over highlighted word without losing clipboard content
vim.keymap.set("x", "<leader>p", '"_dP')

-- --- Buffer Management Mappings ---
-- Shift + h/l to quickly switch between buffers
vim.keymap.set("n", "H", ":bprevious<CR>", { silent = true, desc = "Previous Buffer" })
vim.keymap.set("n", "L", ":bnext<CR>", { silent = true, desc = "Next Buffer" })

-- Space + b + d to delete current buffer
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { silent = true, desc = "Delete Buffer" })

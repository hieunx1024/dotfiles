vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.g.mapleader = " "
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set cursorline")
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "white" })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#ead84e" })
vim.opt.clipboard = "unnamedplus"
vim.opt.hlsearch = true
vim.opt.incsearch = true
-- move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- paste over highlight word
vim.keymap.set("x", "<leader>p", '"_dP')
vim.opt.colorcolumn = "94"
-- clipboard already set above
-- wrap text
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
-- fk llm-ls
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

-- --- Buffer Management Mappings ---
-- Shift + h/l để chuyển qua lại giữa các Buffer cực nhanh
vim.keymap.set("n", "H", ":bprevious<CR>", { silent = true, desc = "Previous Buffer" })
vim.keymap.set("n", "L", ":bnext<CR>", { silent = true, desc = "Next Buffer" })

-- Space + b + d để đóng Buffer hiện tại
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { silent = true, desc = "Delete Buffer" })

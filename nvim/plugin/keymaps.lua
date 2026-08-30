if vim.g.did_load_keymaps_plugin then
	return
end
vim.g.did_load_keymaps_plugin = true

local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local diagnostic = vim.diagnostic


keymap.set("i", "<C-c>", "<Esc>", { noremap = true })


keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Format on save
local function format_and_save()
	vim.lsp.buf.format()
	vim.cmd.write()
end

keymap.set('n', "<C-s>", function()
	format_and_save()
end, { silent = true, desc = 'Format and [s]ave' })
keymap.set('i', "<C-s>", function()
	vim.cmd.stopinsert()
	format_and_save()
end, { silent = true, desc = 'Format and [s]ave' })

-- Yank from current position till end of current line
keymap.set('n', 'Y', 'y$', { silent = true, desc = '[Y]ank to end of line' })

-- Buffer list navigation
keymap.set('n', '[b', vim.cmd.bprevious, { silent = true, desc = 'previous [b]uffer' })
keymap.set('n', ']b', vim.cmd.bnext, { silent = true, desc = 'next [b]uffer' })
keymap.set('n', '[B', vim.cmd.bfirst, { silent = true, desc = 'first [B]uffer' })
keymap.set('n', ']B', vim.cmd.blast, { silent = true, desc = 'last [B]uffer' })

keymap.set('n', '<leader>bn', ":enew<CR>", { desc = '[b]uffer [n]ew' })
keymap.set('n', '<leader>bd', ":bdelete<CR>", { desc = '[b]buffer [d]elete' })
keymap.set('n', '<leader>bl', ":ls<CR>", { desc = '[b]uffer [l]ist' })


-- Resize vertical splits
local toIntegral = math.ceil
keymap.set('n', '<leader>w+', function()
	local curWinWidth = api.nvim_win_get_width(0)
	api.nvim_win_set_width(0, toIntegral(curWinWidth * 3 / 2))
end, { silent = true, desc = 'inc window [w]idth' })
keymap.set('n', '<leader>w-', function()
	local curWinWidth = api.nvim_win_get_width(0)
	api.nvim_win_set_width(0, toIntegral(curWinWidth * 2 / 3))
end, { silent = true, desc = 'dec window [w]idth' })
keymap.set('n', '<leader>h+', function()
	local curWinHeight = api.nvim_win_get_height(0)
	api.nvim_win_set_height(0, toIntegral(curWinHeight * 3 / 2))
end, { silent = true, desc = 'inc window [h]eight' })
keymap.set('n', '<leader>h-', function()
	local curWinHeight = api.nvim_win_get_height(0)
	api.nvim_win_set_height(0, toIntegral(curWinHeight * 2 / 3))
end, { silent = true, desc = 'dec window [h]eight' })

-- Close floating windows [Neovim 0.10 and above]
keymap.set('n', '<leader>fq', function()
	vim.cmd('fclose!')
end, { silent = true, desc = '[f]loating windows: [q]uit/close all' })

-- Remap Esc to switch to normal mode and Ctrl-Esc to pass Esc to terminal
keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Shortcut for expanding to current buffer's directory in command mode
keymap.set('c', '%%', function()
	if fn.getcmdtype() == ':' then
		return fn.expand('%:h') .. '/'
	else
		return '%%'
	end
end, { expr = true, desc = "expand to current buffer's directory" })

local severity = diagnostic.severity

keymap.set('n', "<leader>de", vim.diagnostic.open_float, { desc = "Show [d]iagnostic [e]rror message" })
keymap.set('n', "<leader>dq", vim.diagnostic.setloclist, { desc = "Open [d]iagnostic [q]uickfix list" })
keymap.set('n', '[d', diagnostic.goto_prev, { noremap = true, silent = true, desc = 'previous [d]iagnostic' })
keymap.set('n', ']d', diagnostic.goto_next, { noremap = true, silent = true, desc = 'next [d]iagnostic' })
keymap.set('n', '[e', function()
	diagnostic.goto_prev {
		severity = severity.ERROR,
	}
end, { noremap = true, silent = true, desc = 'previous [e]rror diagnostic' })
keymap.set('n', ']e', function()
	diagnostic.goto_next {
		severity = severity.ERROR,
	}
end, { noremap = true, silent = true, desc = 'next [e]rror diagnostic' })
keymap.set('n', '[w', function()
	diagnostic.goto_prev {
		severity = severity.WARN,
	}
end, { noremap = true, silent = true, desc = 'previous [w]arning diagnostic' })
keymap.set('n', ']w', function()
	diagnostic.goto_next {
		severity = severity.WARN,
	}
end, { noremap = true, silent = true, desc = 'next [w]arning diagnostic' })
keymap.set('n', '[h', function()
	diagnostic.goto_prev {
		severity = severity.HINT,
	}
end, { noremap = true, silent = true, desc = 'previous [h]int diagnostic' })
keymap.set('n', ']h', function()
	diagnostic.goto_next {
		severity = severity.HINT,
	}
end, { noremap = true, silent = true, desc = 'next [h]int diagnostic' })

local function buf_toggle_diagnostics()
	local filter = { bufnr = api.nvim_get_current_buf() }
	diagnostic.enable(not diagnostic.is_enabled(filter), filter)
end

keymap.set('n', '<leader>td', buf_toggle_diagnostics,
	{ noremap = true, silent = true, desc = 'lsp [t]oggle inlay [h]ints' })


--- Disabled keymaps [enable at your own risk]

-- Automatic management of search highlight
-- XXX: This is not so nice if you use j/k for navigation
-- (you should be using <C-d>/<C-u> and relative line numbers instead ;)
--
-- local auto_hlsearch_namespace = vim.api.nvim_create_namespace('auto_hlsearch')
-- vim.on_key(function(char)
--   if vim.fn.mode() == 'n' then
--     vim.opt.hlsearch = vim.tbl_contains({ '<CR>', 'n', 'N', '*', '#', '?', '/' }, vim.fn.keytrans(char))
--   end
-- end, auto_hlsearch_namespace)

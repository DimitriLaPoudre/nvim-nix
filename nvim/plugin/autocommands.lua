if vim.g.did_load_autocommands_plugin then
	return
end
vim.g.did_load_autocommands_plugin = true

local api = vim.api

local tempdirgroup = api.nvim_create_augroup('tempdir', { clear = true })
-- Do not set undofile for files in /tmp
api.nvim_create_autocmd('BufWritePre', {
	pattern = '/tmp/*',
	group = tempdirgroup,
	callback = function()
		vim.cmd.setlocal('noundofile')
	end,
})

-- Disable spell checking in terminal buffers
local nospell_group = api.nvim_create_augroup('nospell', { clear = true })
api.nvim_create_autocmd('TermOpen', {
	group = nospell_group,
	callback = function()
		vim.wo[0].spell = false
	end,
})

-- Vim-cool
vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		if vim.fn.getcmdtype():find("[/?]") then
			vim.opt.hlsearch = true
		end
	end,
})
vim.api.nvim_create_autocmd("CmdlineLeave", {
	callback = function()
		vim.opt.hlsearch = false
	end,
})
--

-- Highlight on yank
local yank_group = api.nvim_create_augroup('yank', { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	group = yank_group,
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})


-- Native completion only in basic buffers
vim.api.nvim_create_autocmd({ "BufEnter", "BufNew" }, {
	group = vim.api.nvim_create_augroup("UserAutocomplete", { clear = true }),
	callback = function(ev)
		local buftype = vim.bo[ev.buf].buftype

		-- Disable completion in special buffers
		if buftype ~= "" then
			vim.bo[ev.buf].autocomplete = false
		end
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"help", "lspinfo", "checkhealth", "qf"
	},
	callback = function(event)
		vim.keymap.set("n", "q", function()
			vim.cmd("close")
		end, { buffer = event.buf, silent = true })
	end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(event)
		local exclude = { "gitcommit" } -- don't remember position in commit messages
		local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
		local lcount = vim.api.nvim_buf_line_count(event.buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- LSP
local keymap = vim.keymap

local function preview_location_callback(_, result)
	if result == nil or vim.tbl_isempty(result) then
		return nil
	end
	local buf, _ = vim.lsp.util.preview_location(result[1])
	if buf then
		local cur_buf = vim.api.nvim_get_current_buf()
		vim.bo[buf].filetype = vim.bo[cur_buf].filetype
	end
end

local function peek_definition()
	local params = vim.lsp.util.make_position_params()
	return vim.lsp.buf_request(0, 'textDocument/definition', params, preview_location_callback)
end

local function peek_type_definition()
	local params = vim.lsp.util.make_position_params()
	return vim.lsp.buf_request(0, 'textDocument/typeDefinition', params, preview_location_callback)
end

--- Don't create a comment string when hitting <Enter> on a comment line
vim.api.nvim_create_autocmd('BufEnter', {
	group = vim.api.nvim_create_augroup('DisableNewLineAutoCommentString', {}),
	callback = function()
		vim.opt.formatoptions = vim.opt.formatoptions - { 'c', 'r', 'o' }
	end,
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		local bufnr = ev.buf
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- Attach plugins
		vim.cmd.setlocal('signcolumn=yes')
		vim.bo[bufnr].bufhidden = 'hide'

		-- Enable completion triggered by <c-x><c-o>
		if client and client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id,
				bufnr, { autotrigger = true, })
		end
		-- vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
		local function desc(description)
			return { noremap = true, silent = true, buffer = bufnr, desc = description }
		end
		keymap.set('n', 'gt', vim.lsp.buf.type_definition, desc('lsp [g]o to [t]ype definition'))
		keymap.set('n', 'K', vim.lsp.buf.hover, desc('[lsp] hover'))
		keymap.set('n', '<leader>pd', peek_definition, desc('lsp [p]eek [d]efinition'))
		keymap.set('n', '<leader>pt', peek_type_definition, desc('lsp [p]eek [t]ype definition'))
		keymap.set('n', 'gi', vim.lsp.buf.implementation, desc('lsp [g]o to [i]mplementation'))
		keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, desc('[lsp] signature help'))
		keymap.set('n', '<leader>rn', vim.lsp.buf.rename, desc('lsp [r]e[n]ame'))
		keymap.set('n', '<leader>ds', vim.lsp.buf.document_symbol, desc('lsp [d]ocument [s]ymbol'))
		keymap.set('n', '<M-CR>', vim.lsp.buf.code_action, desc('[lsp] code action'))
		keymap.set('n', '<M-l>', vim.lsp.codelens.run, desc('[lsp] run code lens'))
		keymap.set('n', 'gr', vim.lsp.buf.references, desc('lsp [g]et [r]eferences'))
		keymap.set('n', '<leader>f', function()
			vim.lsp.buf.format { async = true }
		end, desc('[lsp] [f]ormat buffer'))
		if client and client.server_capabilities.inlayHintProvider then
			keymap.set('n', '<leader>th', function()
				local current_setting = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
				vim.lsp.inlay_hint.enable(not current_setting, { bufnr = bufnr })
			end, desc('lsp [t]oggle inlay [h]ints'))
		end
	end,
})

-- Enable native (builtin) treesitter highlighting & folding per filetype.
-- Uses only Neovim core treesitter (no nvim-treesitter plugin required).
local native_ts_group = api.nvim_create_augroup('treesitter_native', { clear = true })
local SKIP_FT = {
	[''] = true, -- no filetype
	help = true,
	qf = true,
}

api.nvim_create_autocmd('FileType', {
	group = native_ts_group,
	callback = function(event)
		local ft = vim.bo[event.buf].filetype
		if SKIP_FT[ft] then
			return
		end
		local lang = vim.treesitter.language.get_lang(ft)
		if not lang then
			return
		end
		-- Only proceed if the parser is already available (no auto-install).
		if vim.treesitter.language.add(lang) then
			vim.treesitter.start(event.buf, lang)
			-- folds, provided by core treesitter
			vim.wo.foldmethod = 'expr'
			vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		end
	end,
	desc = 'Enable builtin treesitter highlighting and folding',
})

-- More examples, disabled by default

-- Toggle between relative/absolute line numbers
-- Show relative line numbers in the current buffer,
-- absolute line numbers in inactive buffers
-- local numbertoggle = api.nvim_create_augroup('numbertoggle', { clear = true })
-- api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
--   pattern = '*',
--   group = numbertoggle,
--   callback = function()
--     if vim.o.nu and vim.api.nvim_get_mode().mode ~= 'i' then
--       vim.opt.relativenumber = true
--     end
--   end,
-- })
-- api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
--   pattern = '*',
--   group = numbertoggle,
--   callback = function()
--     if vim.o.nu then
--       vim.opt.relativenumber = false
--       vim.cmd.redraw()
--     end
--   end,
-- })

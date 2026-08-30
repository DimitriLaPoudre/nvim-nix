if vim.g.did_load_telescope_plugin then
	return
end
vim.g.did_load_telescope_plugin = true

local telescope = require('telescope')
local actions = require('telescope.actions')

local builtin = require('telescope.builtin')

local layout_config = {
	vertical = {
		width = function(_, max_columns)
			return math.floor(max_columns * 0.99)
		end,
		height = function(_, _, max_lines)
			return math.floor(max_lines * 0.99)
		end,
		prompt_position = 'bottom',
		preview_cutoff = 0,
	},
}

-- Fall back to find_files if not in a git repo
local project_files = function()
	local opts = {} -- define here if you want to define something
	local ok = pcall(builtin.git_files, opts)
	if not ok then
		builtin.find_files(opts)
	end
end

--- Toggle hidden & ignored files on the fly for find_files/live_grep
local function toggle_hidden()
	local picker = require('telescope.actions.state').get_current_picker()
	if not picker then
		return
	end
	local opts = picker.finder.default_opts or {}
	opts.hidden = not opts.hidden
	opts.no_ignore = not opts.no_ignore
	opts.no_ignore_parent = not opts.no_ignore_parent
	opts.to_grep_args = function(o)
		local cmd = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column',
			'--smart-case' }
		if o.hidden then
			cmd[#cmd + 1] = '--hidden'
		end
		if o.no_ignore then
			cmd[#cmd + 1] = '--no-ignore'
		end
		return cmd
	end
	picker:close()
	builtin.find_files(opts)
end

--- Copy the relative path of the selected entry to the '+' register
local function copy_relative_path()
	local entry = require('telescope.actions.state').get_selected_entry()
	if not entry then
		return
	end
	local path = entry.path or entry.value
	if path then
		vim.fn.setreg('+', vim.fn.fnamemodify(path, ':.'))
	end
end

telescope.setup {
	defaults = {
		cache_picker = true,
		path_display = {
			'truncate',
		},
		file_ignore_patterns = {
			'^%.git/',
			'^node_modules/',
			'^build/',
			'^%.venv/',
			'^coverage/',
			'^dist/',
			'^target/',
		},
		layout_strategy = 'vertical',
		layout_config = layout_config,
		mappings = {
			i = {
				['<C-q>'] = actions.send_to_qflist,
				['<C-l>'] = actions.send_to_loclist,
				-- ['<esc>'] = actions.close,
				['<C-s>'] = actions.cycle_previewers_next,
				['<C-a>'] = actions.cycle_previewers_prev,
			},
			n = {
				q = actions.close,
			},
		},
		preview = {
			treesitter = true,
		},
		history = {
			path = vim.fn.stdpath('data') .. '/telescope_history.sqlite3',
			limit = 1000,
		},
		color_devicons = true,
		set_env = { ['COLORTERM'] = 'truecolor' },
		prompt_prefix = ' ',
		selection_caret = '  ',
		entry_prefix = '  ',
		initial_mode = 'insert',
		vimgrep_arguments = {
			'rg',
			'-L',
			'--color=never',
			'--no-heading',
			'--with-filename',
			'--line-number',
			'--column',
			'--smart-case',
		},
	},
	pickers = {
		find_files = {
			hidden = true,
			no_ignore = true,
			mappings = {
				i = {
					['<S-h>'] = toggle_hidden,
					['<C-y>'] = copy_relative_path,
				},
				n = {
					['<S-h>'] = toggle_hidden,
					['<C-y>'] = copy_relative_path,
				},
			},
		},
		live_grep = {
			hidden = true,
			no_ignore = true,
			mappings = {
				i = {
					['<S-h>'] = toggle_hidden,
				},
				n = {
					['<S-h>'] = toggle_hidden,
				},
			},
		},
	},
	extensions = {
		fzy_native = {
			override_generic_sorter = false,
			override_file_sorter = true,
		},
	},
}

telescope.load_extension('fzy_native')

-- Top Pickers
vim.keymap.set('n', '<leader><space>', function()
	project_files()
end, { desc = 'Smart Find Files' })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Fuzzy find in current buffer' })
vim.keymap.set('n', '<leader>:', builtin.command_history, { desc = 'Command History' })

-- find
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fn', function()
	builtin.find_files({ cwd = vim.fn.stdpath('config') })
end, { desc = 'Find Neovim config files' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent' })

-- Grep
vim.keymap.set('n', '<leader>sB', function()
	builtin.live_grep({ grep_open_files = true })
end, { desc = 'Grep Open Buffers' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Grep' })
vim.keymap.set({ 'n', 'x' }, '<leader>sw', builtin.grep_string, { desc = 'Visual selection or word' })

-- search
vim.keymap.set('n', '<leader>s"', builtin.registers, { desc = 'Registers' })
vim.keymap.set('n', '<leader>s/', builtin.search_history, { desc = 'Search History' })
vim.keymap.set('n', '<leader>sa', builtin.autocommands, { desc = 'Autocmds' })
vim.keymap.set('n', '<leader>sc', builtin.command_history, { desc = 'Command History' })
vim.keymap.set('n', '<leader>sC', builtin.commands, { desc = 'Commands' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>sD', function()
	builtin.diagnostics({ bufnr = 0 })
end, { desc = 'Buffer Diagnostics' })
vim.keymap.set('n', '<leader>sH', builtin.highlights, { desc = 'Highlights' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Keymaps' })
vim.keymap.set('n', '<leader>sm', builtin.marks, { desc = 'Marks' })
vim.keymap.set('n', '<leader>sM', builtin.man_pages, { desc = 'Man Pages' })
vim.keymap.set('n', '<leader>sq', builtin.quickfix, { desc = 'Quickfix List' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Resume' })
vim.keymap.set('n', '<leader>sT', builtin.colorscheme, { desc = 'Colorschemes' })

-- LSP
vim.keymap.set('n', 'gd', builtin.lsp_definitions, { desc = 'Goto Definition' })
vim.keymap.set('n', 'gD', builtin.lsp_declarations, { desc = 'Goto Declaration' })
vim.keymap.set('n', 'gR', builtin.lsp_references, { desc = 'References' })
vim.keymap.set('n', 'gI', builtin.lsp_implementations, { desc = 'Goto Implementation' })
vim.keymap.set('n', 'gy', builtin.lsp_type_definitions, { desc = 'Goto [y]pe Definition' })
vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols, { desc = 'LSP Symbols' })
vim.keymap.set('n', '<leader>sS', builtin.lsp_workspace_symbols, { desc = 'LSP Workspace Symbols' })
vim.keymap.set('n', 'gai', builtin.lsp_incoming_calls, { desc = 'Calls Incoming' })
vim.keymap.set('n', 'gao', builtin.lsp_outgoing_calls, { desc = 'Calls Outgoing' })

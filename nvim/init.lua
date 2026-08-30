vim.loader.enable()

local cmd = vim.cmd
local opt = vim.opt

-- <leader> key. Defaults to `\`. Some people prefer space.
-- The default leader is '\'. Some people prefer <space>. Uncomment this if you do, too.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- See :h <option> to see what the options do

-- Search down into subfolders
opt.path = vim.o.path .. '**'

opt.number = true         -- Line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true     -- Highlight current line
opt.wrap = true           -- Wrap lines
opt.scrolloff = 10        -- Keep 10 lines above/below cursor
-- opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Indentation
opt.tabstop = 4    -- Tab width
opt.shiftwidth = 4 -- Indent width
-- opt.softtabstop = 4 -- Soft tab stop
-- opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Smart auto-indenting
opt.autoindent = true  -- Copy indent from current line

-- Search settings
opt.ignorecase = true -- Case insensitive search
opt.smartcase = true  -- Case sensitive if uppercase in search
opt.hlsearch = true   -- Don't highlight search results
opt.incsearch = true  -- Show matches as you type

-- Visual settings
opt.termguicolors = true                        -- Enable 24-bit colors
opt.signcolumn = "yes"                          -- Always show sign column
opt.showmatch = false                           -- Highlight matching brackets
-- opt.matchtime = 2 -- How long to show matching bracket
opt.cmdheight = 1                               -- Command line height
opt.showmode = false                            -- Don't show mode in command line
opt.pumheight = 0                               -- Popup menu height
opt.pumblend = 0                                -- Popup menu transparency
opt.winblend = 0                                -- Floating window transparency
opt.winborder = "bold"
opt.completeopt = "menu,menuone,noselect,popup" -- Completion options
opt.autocomplete = true                         -- Enables the overall native completion feature.
opt.conceallevel = 0                            -- Don't mask any special caracter in styliser file like .md
opt.confirm = true                              -- Confirm to save changes before exiting modified buffer
opt.concealcursor = ""                          -- Don't hide cursor line markup
opt.synmaxcol = 3000                            -- Syntax highlighting limit
opt.ruler = false                               -- Disable the default ruler (line,row)
opt.virtualedit = "block"                       -- Allow cursor to move where there is no text in visual block mode
opt.winminwidth = 5                             -- Minimum window width

-- File handling
opt.backup = false      -- Don't create backup files
opt.writebackup = false -- Don't create backup before writing
opt.swapfile = false    -- Don't create swap files
opt.undofile = true     -- Persistent undo
opt.undolevels = 1000
-- opt.undodir = vim.fn.expand("~/.vim/undodir") -- Undo directory
opt.updatetime = 250 -- Faster completion
opt.timeoutlen = 400 -- Lower than default (1000) to quickly trigger which-key
opt.ttimeoutlen = 0  -- Key code timeout
opt.autoread = true  -- Auto reload files changed outside vim
opt.autowrite = true -- Auto save

-- Behavior settings
opt.hidden = true                                       -- Allow hidden buffers
opt.errorbells = false                                  -- No error bells
opt.backspace = "indent,eol,start"                      -- Better backspace behavior
opt.autochdir = false                                   -- Don't auto change directory
opt.iskeyword:append("-")                               -- Treat dash as part of word
-- opt.path:append("**") -- include subdirectories in search
opt.selection = "inclusive"                             -- Selection behavior
opt.mouse = "a"                                         -- Enable mouse support
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.modifiable = true                                   -- Allow buffer modifications
opt.encoding = "UTF-8"                                  -- Set encoding

-- Folding settings
opt.smoothscroll = true
opt.foldmethod = "syntax"
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"

-- Split behavior
opt.splitright = true -- Vertical splits go right
opt.splitbelow = true -- Horizontal splits go below
opt.splitkeep = "cursor"

-- Command-line completion
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Better diff options
opt.diffopt:append("linematch:60")

-- Performance improvements
opt.redrawtime = 10000
opt.maxmempattern = 20000

-- Create undo directory if it doesn't exist
-- local undodir = vim.fn.expand("~/.vim/undodir")
-- if vim.fn.isdirectory(undodir) == 0 then
--   vim.fn.mkdir(undodir, "p")
-- end

vim.g.autoformat = true

opt.fillchars = {
	foldopen = "-",
	foldclose = "+",
	fold = ".",
	foldsep = "|",
	eob = " ",
}

opt.linebreak = true  -- Wrap lines at convenient points
opt.list = true       -- Show some invisible characters (tabs...
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 4    -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })

opt.inccommand = "split" -- Preview substitutions live, as you type!

vim.g.markdown_recommended_style = 0

vim.filetype.add({
	extension = {
		env = "dotenv",
	},
	filename = {
		[".env"] = "dotenv",
		["env"] = "dotenv",
	},
	pattern = {
		["%.env%.[%w_.-]+"] = "dotenv",
	},
})

-- Configure Neovim diagnostic messages

local function prefix_diagnostic(prefix, diagnostic)
	return string.format(prefix .. ' %s', diagnostic.message)
end

vim.diagnostic.config {
	virtual_text = {
		prefix = '',
		format = function(diagnostic)
			local severity = diagnostic.severity
			if severity == vim.diagnostic.severity.ERROR then
				return prefix_diagnostic('󰅚', diagnostic)
			end
			if severity == vim.diagnostic.severity.WARN then
				return prefix_diagnostic('⚠', diagnostic)
			end
			if severity == vim.diagnostic.severity.INFO then
				return prefix_diagnostic('ⓘ', diagnostic)
			end
			if severity == vim.diagnostic.severity.HINT then
				return prefix_diagnostic('󰌶', diagnostic)
			end
			return prefix_diagnostic('■', diagnostic)
		end,
	},
	signs = {
		text = {
			-- Requires Nerd fonts
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	},
	update_in_insert = false,
	underline = true,
	severity_sort = true,
	float = {
		focusable = false,
		style = 'minimal',
		border = 'rounded',
		source = 'if_many',
		header = '',
		prefix = '',
	},
}

-- Native plugins
cmd.filetype('plugin', 'indent', 'on')
cmd.packadd('cfilter') -- Allows filtering the quickfix list with :cfdo

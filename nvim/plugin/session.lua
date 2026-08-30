if vim.g.did_load_session_plugin then
	return
end
vim.g.did_load_session_plugin = true

local sessions = require("mini.sessions")

sessions.setup({
	-- Whether to read default session if Neovim opened without file arguments
	autoread = false,

	-- Whether to write currently read session before leaving it
	autowrite = false,

	-- Directory where global sessions are stored (use `''` to disable)
	directory = vim.fn.stdpath("data") .. "/sessions",

	-- File for local session (use `''` to disable)
	-- file = 'Session.vim',

	-- Whether to force possibly harmful actions (meaning depends on function)
	force = { read = false, write = true, delete = false },

	-- Hook functions for actions. Default `nil` means 'do nothing'.
	hooks = {
		-- Before successful action
		pre = { read = nil, write = nil, delete = nil },
		-- After successful action
		post = { read = nil, write = nil, delete = nil },
	},

	-- Whether to print session path after action
	verbose = { read = false, write = true, delete = true },
})


local function session_name()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		sessions.write(session_name())
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	nested = true,
	callback = function()
		if vim.fn.argc() == 0 then
			sessions.read(session_name())
		end
	end,
})

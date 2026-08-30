if vim.g.did_load_session_plugin then
	return
end
vim.g.did_load_session_plugin = true

require("mini.sessions").setup({
	-- Whether to read default session if Neovim opened without file arguments
	autoread = true,

	-- Whether to write currently read session before leaving it
	autowrite = true,

	-- Directory where global sessions are stored (use `''` to disable)
	-- directory = --<"session" subdir of user data directory from |stdpath()|>,

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


vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		MiniSessions.write("last")
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	nested = true,
	callback = function()
		MiniSessions.read("last")
	end,
})

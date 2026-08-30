if vim.g.did_load_grug_far_plugin then
	return
end
vim.g.did_load_grug_far_plugin = true

local gf = require("grug-far")

gf.setup({})

-- Keymaps
vim.keymap.set("n", "<leader>r", function()
	gf.open({})
end, { desc = "Open GrugFar" })

vim.keymap.set("n", "<leader>rw", function()
	gf.open({
		prefills = { search = vim.fn.expand("<cword>") },
	})
end, { desc = "Search cursor [w]ord in GrugFar" })

vim.keymap.set("n", "<leader>r/", function()
	gf.open({
		prefills = { paths = vim.fn.expand("%") },
	})
end, { desc = "Open GrugFar in the current file" })

-- Autocmds
vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('grug-far-keybindings', { clear = true }),
	pattern = { 'grug-far' },
	callback = function()
		vim.keymap.set('n', '<C-c>', function()
			gf.get_instance(0):close()
		end, { buffer = true, desc = 'Fermer le buffer GrugFar' })
		vim.keymap.set('n', '<leader>bd', function()
			gf.get_instance(0):close()
		end, { buffer = true, desc = 'Fermer le buffer GrugFar' })
	end,
})

if vim.g.did_load_animation_plugin then
	return
end
vim.g.did_load_animation_plugin = true

require("mini.animate").setup({})

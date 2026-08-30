if vim.g.did_load_plugins_plugin then
	return
end
vim.g.did_load_plugins_plugin = true

-- many plugins annoyingly require a call to a 'setup' function to be loaded,
-- even with default configs

require('lualine').setup()
require('mini.tabline').setup()
require('mini.ai').setup()
require('mini.move').setup()
require('mini.pairs').setup()
require('mini.surround').setup()

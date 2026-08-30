-- Exit if the language server isn't available
if vim.fn.executable('gopls') ~= 1 then
	return
end

vim.lsp.enable('gopls')

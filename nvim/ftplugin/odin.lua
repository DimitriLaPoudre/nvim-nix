-- Exit if the language server isn't available
if vim.fn.executable('ols') ~= 1 then
	return
end

vim.lsp.enable({ "ols" })

" nnoremap <buffer> dd :echo 'Deletions would happen here'
noremap <buffer> dd :call mysql#DeleteRow()<cr>
nnoremap <buffer> <silent> s :SQHSortResults -f<CR>
nnoremap <buffer> <silent> S :SQHSortResults -fr<CR>
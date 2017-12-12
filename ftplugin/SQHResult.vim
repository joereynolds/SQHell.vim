setlocal nostartofline

nnoremap <buffer> dd :call mysql#DeleteRow()<cr>
nnoremap <buffer> <silent> s :SQHSortResults -f<CR>
nnoremap <buffer> <silent> S :SQHSortResults -fr<CR>
nnoremap <buffer> <silent> e :call sqhell#EditRow()<cr>
nnoremap <buffer> <silent> i :call sqhell#InsertRow()<cr>

" nnoremap <buffer> dd :echo 'Deletions would happen here'
noremap <buffer> dd :call mysql#DeleteRow(expand('<cword>'))<cr>

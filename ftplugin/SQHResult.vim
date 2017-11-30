" nnoremap <buffer> dd :echo 'Deletions would happen here'
noremap <buffer> dd :call mysql#DeleteRow()<cr>

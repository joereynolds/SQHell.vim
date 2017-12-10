"Select * from the selected table
noremap <buffer> e :call sqhell#ShowTablesForDatabase(expand('<cword>'))<cr>
noremap <buffer> dd :call mysql#DropDatabase(expand('<cword>'), 1)<cr>
nnoremap <buffer> c :call sqhell#CreateDatabase("", 1)<cr>

"Select * from the selected table
noremap <buffer> e :call mysql#ShowTablesForDatabase(expand('<cword>'))<cr>
noremap <buffer> dd :call mysql#DropDatabase(expand('<cword>'), 1)<cr>

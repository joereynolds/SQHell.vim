"Select * from the selected table
noremap <buffer> e :call mysql#ShowTablesForDatabase(expand('<cword>'))<cr>

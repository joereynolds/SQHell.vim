"Select * from the selected table
noremap <buffer> e :call ShowTablesForDatabase(expand('<cword>'))<cr>

"Select * from the selected table
noremap <buffer> e :call mysql#ShowRecordsInTable(expand('<cword>'))<cr>
noremap <buffer> K :call mysql#DescribeTable(expand('<cword>'))<cr>

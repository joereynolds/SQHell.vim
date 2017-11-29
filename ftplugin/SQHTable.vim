"Select * from the selected table
noremap <buffer> e :call mysql#ShowRecordsInTable(expand('<cword>'))<cr>
noremap <buffer> K :call mysql#DescribeTable(expand('<cword>'))<cr>
noremap <buffer> dd :call mysql#DropTableSQHTableBuf(expand('<cword>'), 1)<cr>

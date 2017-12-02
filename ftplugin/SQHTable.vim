"Select * from the selected table
noremap <buffer> e :call sqhell#ShowRecordsInTable(expand('<cword>'))<cr>
noremap <buffer> K :call sqhell#DescribeTable(expand('<cword>'))<cr>
noremap <buffer> dd :call mysql#DropTableSQHTableBuf(expand('<cword>'), 1)<cr>

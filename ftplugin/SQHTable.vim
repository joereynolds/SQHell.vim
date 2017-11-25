"Select * from the selected table
noremap <buffer> e :call ShowRecordsInTable(expand('<cword>'))<cr>
noremap <buffer> K :call DescribeTable(expand('<cword>'))<cr>

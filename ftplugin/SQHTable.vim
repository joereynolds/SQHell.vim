"Select * from the selected table
noremap <buffer> e :call ShowRecordsInTable()<cr>
noremap <buffer> K :call DescribeTable(getline('.'))<cr>

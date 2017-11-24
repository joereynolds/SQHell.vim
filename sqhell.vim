"The primary key to do operations on.
"This can be changed here or via the
"MarkAsPk command -- TODO
let g:primary_key = 'id'

"The connection details for your database
"Right now these are hardcoded to mysql.
let g:connection_details = '---------------------------------------------' "[redacted]

"Move these to the relevant ftplugin"
augroup sqh_read
    autocmd FileType SQHResult nnoremap <buffer> dd :echom 'my dd test'
augroup END

"Mysql's execute command"
function! ExecuteCommand(command)
    let system_command = g:connection_details . ' <<< "' . a:command . '" | column -t'
    let query_results = system(system_command)
    call InsertResultsToNewBuffer('this does not work yet', query_results)
endfunction

function! ExecuteLine()
    let line = getline('.')
    call ExecuteCommand(line)
endfunction

"TODO - If none passed in, do the current file"
function! ExecuteFile(file)
    let file_content = join(readfile(a:file), "\n")
    call ExecuteCommand(file_content)
endfunction

"buffer_type is what we set our filetype to. We do this so that we can
"do decent buffer context commands
"query results is a string of all of the results from the query"
function! InsertResultsToNewBuffer(buffer_type, query_results)
    new | put =a:query_results
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal filetype=SQHResult "Make this filetype come from a:buffer_type
                                "Currently we pass it as a string and you
                                "can't set a filetype to a string, hmmm.
endfunction


"Example call
" call ExecuteCommand('SELECT * FROM users LIMIT 5')
" call ExecuteFile('/tmp/some-file')

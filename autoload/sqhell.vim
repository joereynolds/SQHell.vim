function! sqhell#SwitchConnection(connection)
    let valid_connections = keys(g:sqh_connections)

    if index(valid_connections, a:connection) == -1
        echom '[SQHELL] host must be one of [' . join(valid_connections, ', ') . ']'
        return
    endif

    let g:sqh_connection = a:connection

endfunction

"Inserts SQL results into a new temporary buffer"
function! sqhell#ExecuteCommand(command)
    execute "call sqhell#InsertResultsToNewBuffer('SQHResult', " . g:sqh_provider . "#GetResultsFromQuery(a:command))"
endfunction

function! sqhell#Execute() range
    "TODO extract the block selection out so we can test it
    let l:previous_register_content = @"
    silent! execute a:firstline . ',' . a:lastline . 'y'
    let l:query = @"
    "Restore whatever was in here back to normal
    let @" = l:previous_register_content
    call sqhell#ExecuteCommand(l:query)
endfunction

"Execute the given file
function! sqhell#ExecuteFile(...)
    let _file = get(a:, 1)

    if a:1 == ''
        let file_content = join(getline(1, '$'))
    else
        let file_content = join(readfile(_file), "\n")
    endif

    call sqhell#ExecuteCommand(file_content)
endfunction

function! sqhell#InsertResultsToNewBuffer(local_filetype, query_results)
    new | put =a:query_results

    execute "call " . g:sqh_provider . "#PostBufferFormat()"

    "This prevents newline characters from literally rendering out
    "Keeping this as a comment just incase anyone decides to get
    "it working
    " normal :4,$s/\(|\)\@<!\n "This actually works when typed manually

    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nowrap
    execute 'setlocal filetype=' . a:local_filetype
endfunction

function! sqhell#SwitchConnection(connection)
    let g:sqh_connection = a:connection
    let valid_connections = keys(g:sqh_connections)

    if index(valid_connections, a:connection) == -1
        echom '[SQHELL] host must be one of [' . join(valid_connections, ', ') . ']'
    endif

endfunction

"Inserts SQL results into a new temporary buffer"
function! sqhell#ExecuteCommand(command)
    execute "call sqhell#InsertResultsToNewBuffer('SQHResult', " . g:sqh_provider . "#GetResultsFromQuery(a:command))"
endfunction

function! sqhell#ExecuteLine()
    call sqhell#ExecuteCommand(getline('.'))
endfunction

function! sqhell#InsertResultsToNewBuffer(local_filetype, query_results)
    new | put =a:query_results

    "Remove mysql junk"
    "this should probably go into the ftplugin on BufReadPre
    normal gg2dd

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

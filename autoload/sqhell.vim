"This is for completion of the
":SQHSwitchConnection command"
function! sqhell#GetHosts(arglead, cmdline, cursorPos)
    return join(keys(g:sqh_connections), "\n")
endfunction

function! sqhell#SwitchConnection(connection)
    let l:valid_connections = keys(g:sqh_connections)

    if index(l:valid_connections, a:connection) == -1
        echom '[SQHELL] host must be one of [' . join(l:valid_connections, ', ') . ']'
        return
    endif

    let g:sqh_connection = a:connection
endfunction

"Inserts SQL results into a new temporary buffer"
function! sqhell#ExecuteCommand(command)
    execute "call sqhell#InsertResultsToNewBuffer('SQHResult', " . g:sqh_provider . "#GetResultsFromQuery(a:command), 1)"
    let b:last_query = a:command
endfunction

function! sqhell#Execute(command, bang) range

    if a:bang == 1
        return sqhell#ExecuteCommand(a:command)
    endif

    let l:previous_register_content = @"
    silent! execute a:firstline . ',' . a:lastline . 'y'
    let l:query = @"
    "Restore whatever was in here back to normal
    let @" = l:previous_register_content
    call sqhell#ExecuteCommand(l:query)
endfunction

"Execute the given file
function! sqhell#ExecuteFile(...)
    let l:file_content = join(getline(1, '$'), "\n")

    if a:1 !=? ''
        let l:file_content = join(readfile(a:1), "\n")
    endif

    call sqhell#ExecuteCommand(l:file_content)
endfunction

function! sqhell#InsertResultsToNewBuffer(local_filetype, query_results, format)

    if g:sqh_results_output ==? 'nosplit'
        enew! | put =a:query_results
    else
        new | put =a:query_results
    endif

    if (a:format)
        execute "call " . g:sqh_provider . "#PostBufferFormat()"
    endif

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

"Proxies to the provider of choice
function! sqhell#ShowTablesForDatabase(database)
    execute 'call ' . g:sqh_provider . '#ShowTablesForDatabase("' . a:database.'")'
endfunction

function! sqhell#ShowRecordsInTable(table)
    execute 'call ' . g:sqh_provider . '#ShowRecordsInTable("' . a:table .'")'
endfunction

function! sqhell#DescribeTable(table)
    execute 'call ' . g:sqh_provider . '#DescribeTable("' . a:table .'")'
endfunction

function! sqhell#GetColumnName()
    execute 'let ret = ' . g:sqh_provider . '#GetColumnName()'
    return ret
endfunction

function! sqhell#GetColumnValue()
    execute 'let ret = ' . g:sqh_provider . '#GetColumnValue()'
    return ret
endfunction

function! sqhell#CreateCSVFromRow(row)
    execute 'let ret = ' . g:sqh_provider . '#CreateCSVFromRow(a:row)'
    return ret
endfunction

function! sqhell#GetTableHeader()
    execute 'let ret = ' . g:sqh_provider . '#GetTableHeader()'
    return ret
endfunction

function! sqhell#GetTableName()
    let l:savewin = winnr()
    wincmd p
    let l:table = expand('<cword>')
    let l:db = sqhell#TrimString(g:sqh_database)
    execute l:savewin . "wincmd w"
    return [l:table, l:db]
endfunction

function! sqhell#TrimString(str)
    return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

"Returns a friendly string for confirm dialogs
function! sqhell#GeneratePrompt(query)
    return '[SQHELL] Execute "' . a:query . '"?'
endfunction

"statusline variable(s)
function! sqhell#Host()
    return g:sqh_connection
endfunction

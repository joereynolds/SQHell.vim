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

function! sqhell#GetColumnName()
    let savecurpos = getcurpos()
    call cursor(1, savecurpos[2])
    let attr = expand('<cword>')
    if(attr =~ "^\+-")
        call cursor(2, savecurpos[2])
    endif
    let start = col('.')
    if(getline('.')[col('.')-1] != '|')
        normal F|
        let start = col('.')
    endif
    normal f|
    let end = col('.')-2
    let attr = getline('.')[start:end]
    let attr = substitute(attr, '^\s*\(.\{-}\)\s*$', '\1', '')
    call setpos('.', savecurpos)
    return attr
endfunction

function! sqhell#GetColumnValue()
    let savecurpos = getcurpos()
    let start = col('.')
    if(getline('.')[start-1] != '|')
        normal F|
        let start = col('.')
    endif
    normal f|
    let end = col('.')-2
    let val = getline('.')[start:end]
    let val = substitute(val, '^\s*\(.\{-}\)\s*$', '\1', '')
    call setpos('.', savecurpos)
    return val
endfunction

function! sqhell#GetTableName()
    let savewin = winnr()
    wincmd p
    let table = expand('<cword>')
    let tmp_db = mysql#GetDatabaseName()
    let db = substitute(tmp_db, '^\s*\(.\{-}\)\s*$', '\1', '')
    execute savewin . "wincmd w"
    return [table, db]
endfunction

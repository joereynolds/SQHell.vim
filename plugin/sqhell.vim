if exists('g:loaded_sqhell')
    finish
endif

let g:loaded_sqhell = 1

"Connection details for your database (currently hardcoded to mysql)
let g:user = get(g:, 'user', '')
let g:password = get(g:, 'password', '')
let g:host = get(g:, 'host', '')
let g:connection_details = 'mysql -u' . g:user . ' -p' . g:password . ' -h' . g:host
let g:result_buffer = -1

"Runs the command returns the results
function! GetResultsFromQuery(command)
    let system_command = g:connection_details . ' <<< "' . a:command . '" | column -t'
    let query_results = system(system_command)
    return query_results
endfunction

"Inserts SQL results into a new temporary buffer"
function! ExecuteCommand(command)
    call InsertResultsToNewBuffer('SQHResult', GetResultsFromQuery(a:command))
endfunction

"Execute the current line
function! ExecuteLine()
    call ExecuteCommand(getline('.'))
endfunction

"TODO this is broken
"Execute the given file, or the current file if no file passed
function! ExecuteFile(...)
    let file_to_run = get(a:, 1, expand('%'))
    let file_content = join(readfile(file_to_run), "\n")
endfunction

function! InsertResultsToNewBuffer(local_filetype, query_results)

    " if g:result_buffer == -1
        new | put =a:query_results
        " let g:result_buffer = bufnr("$")
    " else
        " buffers! g:result_buffer
    " endif

    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    execute 'setlocal filetype=' . a:local_filetype
endfunction

"Shows all tables for a given database
"Can also be ran by pressing 'e' in
"an SQHDatabase buffer
function! ShowTablesForDatabase(database)
    call InsertResultsToNewBuffer('SQHTable', GetResultsFromQuery('SHOW TABLES FROM ' . a:database))
endfunction

"This is ran when press 'K' on an SQHTable buffer"
function! DescribeTable(table)
    let db = GetDatabaseName()
    let query = 'DESCRIBE ' . db . '.' . a:table
    call InsertResultsToNewBuffer('SQHUnspecified', GetResultsFromQuery(query))
endfunction

function! ShowDatabases()
    call InsertResultsToNewBuffer('SQHDatabase', GetResultsFromQuery('SHOW DATABASES'))
endfunction

"Tables_in_users_table => users_table"
function! GetDatabaseName()
    let current_database = split(getline(search('Tables_in_')), 'Tables_in_')[0]
    return current_database
endfunction

"This is ran when we press 'e' on an SQHTable buffer
function! ShowRecordsInTable()
    let current_table = getline('.')
    let db = GetDatabaseName()
    let query = 'SELECT * FROM ' . db . '.' . current_table . ' LIMIT 100'
    call ExecuteCommand(query)
endfunction

"Expose our functions for the user
command! -nargs=0 SQHShowDatabases :call ShowDatabases()
command! -nargs=1 SQHShowTablesForDatabase :call ShowTablesForDatabase(<q-args>)
command! -nargs=? SQHExecuteFile :call ExecuteFile(<q-args>)
command! -nargs=1 SQHExecuteCommand :call ExecuteCommand(<q-args>)
command! -nargs=0 SQHExecuteLine :call ExecuteLine()

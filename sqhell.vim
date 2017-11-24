"The connection details for your database
"Right now these are hardcoded to mysql.
let g:user = get(g:, 'user', '')
let g:password = get(g:, 'password', '')
let g:host = get(g:, 'host', '')
let g:connection_details = 'mysql -u' . g:user . ' -p' . g:password . ' -h' . g:host

"TODO Move these to the relevant ftplugin"
augroup sqh_read
    autocmd!
    autocmd FileType SQHResult nnoremap <buffer> dd :echom 'my dd test'
    autocmd FileType SQHTable nnoremap <buffer> e :call ShowDataFromTable()<cr>
augroup END

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
    let line = getline('.')
    call ExecuteCommand(line)
endfunction

"TODO - If none passed in, do the current file"
"Execute the given file, or the current file if no file passed
function! ExecuteFile(file)
    let file_content = join(readfile(a:file), "\n")
endfunction

function! InsertResultsToNewBuffer(local_filetype, query_results)
    new | put =a:query_results
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    execute 'setlocal filetype=' . a:local_filetype
endfunction

function! SQHShowTables(database)
    call InsertResultsToNewBuffer('SQHTable', GetResultsFromQuery('SHOW TABLES FROM ' . a:database))
endfunction

function! SQHShowDatabases()
    call InsertResultsToNewBuffer('SQHDatabase', GetResultsFromQuery('SHOW DATABASES'))
endfunction

"This is ran when we press 'e' on a SQHTable buffer"
function! ShowDataFromTable()
    let current_table = getline('.')
    let current_database = split(getline(search('Tables_in_')), 'Tables_in_')[0]
    let query = 'SELECT * FROM ' . current_database . '.' . current_table . ' LIMIT 100'
    call ExecuteCommand(query)
endfunction

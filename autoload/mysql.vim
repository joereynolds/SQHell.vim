function! mysql#GetResultsFromQuery(command)
    let user = g:sqh_connections[g:sqh_connection]['user']
    let password = g:sqh_connections[g:sqh_connection]['password']
    let host = g:sqh_connections[g:sqh_connection]['host']

    let connection_details = 'mysql --unbuffered -u' . user . ' -p' . password . ' -h' . host
    let system_command = connection_details . " --table -e " . shellescape(a:command)
    let query_results = system(system_command)
    return query_results
endfunction

"Tables_in_users_table => users_table"
function! mysql#GetDatabaseName()
    let savecur = getcurpos()
    let raw_database = split(getline(search('Tables_in_')), 'Tables_in_')[1]
    call setpos('.', savecur)
    let current_database = substitute(raw_database, '|', '', '')
    return current_database
endfunction

"This is ran when press 'K' on an SQHTable buffer"
function! mysql#DescribeTable(table)
    let db = mysql#GetDatabaseName()
    let query = 'DESCRIBE ' . db . '.' . a:table
    call sqhell#InsertResultsToNewBuffer('SQHUnspecified', mysql#GetResultsFromQuery(query))
endfunction

"This is ran when we press 'e' on an SQHTable buffer
function! mysql#ShowRecordsInTable(table)
    let db = mysql#GetDatabaseName()
    let query = 'SELECT * FROM ' . db . '.' . a:table . ' LIMIT ' . g:sqh_results_limit
    call sqhell#ExecuteCommand(query)
endfunction

function! mysql#ShowDatabases()
    call sqhell#InsertResultsToNewBuffer('SQHDatabase', mysql#GetResultsFromQuery('SHOW DATABASES'))
endfunction

"Shows all tables for a given database
"Can also be ran by pressing 'e' in
"an SQHDatabase buffer
function! mysql#ShowTablesForDatabase(database)
    call sqhell#InsertResultsToNewBuffer('SQHTable', mysql#GetResultsFromQuery('SHOW TABLES FROM ' . a:database))
endfunction

"Drops database at cursor
"Can also be ran by pressing 'dd' in
"a SQHDatabase buffer
"Arguments:
" - database: string, the database name
" - show: boolean, show databases?
function! mysql#DropDatabase(database, show)
    if(!g:i_like_to_live_life_dangerously)
        let prompt = confirm('Do you really want to drop the database: ' . a:database . '?', "&Yes\n&No", 2)
    else
        let prompt = 1
    endif
    if(prompt == 1)
        call mysql#GetResultsFromQuery('DROP DATABASE ' . a:database)
        if(a:show)
          :bd
          call mysql#ShowDatabases()
        endif
    endif
endfunction

"Drops table by pressing 'dd'
"in a SQHTable buffer
"Arguments:
" - table: string, the table name
" - show: boolean, show databases?
function! mysql#DropTableSQHTableBuf(table, show)
    let db = mysql#GetDatabaseName()
    call mysql#DropTableFromDatabase(db, a:table, a:show)
endfunction

"Drops table
"Arguments:
" - database: string, the database name
" - table: string, the table name
" - show: boolean, show databases?
function! mysql#DropTableFromDatabase(database, table, show)
    if(!g:i_like_to_live_life_dangerously)
        let prompt = confirm('Do you really want to drop the table: ' . a:table . ' from the database: ' . a:database . "?", "&Yes\n&No", 2)
    else
        let prompt = 1
    endif
    if(prompt == 1)
        call mysql#GetResultsFromQuery('DROP TABLE ' . a:database . "." . a:table)
        if(a:show)
            :bd
            call mysql#ShowTablesForDatabase(a:database)
        endif
    endif
endfunction

"Each provider may paste some extra
"crap that is irrelevant to us
"Use this function to customise
"the removal of said crap...
function! mysql#PostBufferFormat()
    normal gg2dd
endfunction

"Deletes table row(s) by pressing 'dd'
"in a SQHResult buffer
"Arguments:
" - row: string, the where condition for deleting
function! mysql#DeleteRow(row)
    let attr = sqhell#GetColumnName()
    let list = sqhell#GetTableName()
    let table = list[0]
    let db = list[1]
    if(!g:i_like_to_live_life_dangerously)
        let prompt = confirm('Do you really want to delete all table rows where column ' . attr . '=' . a:row . ' in ' . db . '.' . table . '?', "&Yes\n&No", 2)
    else
        let prompt = 1
    endif
    if(prompt == 1)
        call mysql#GetResultsFromQuery('DELETE FROM ' . db . '.' . table . ' WHERE ' . attr . '=' . "\'" . a:row . "\'")
        :bd
        let query = 'SELECT * FROM ' . db . '.' . table . ' LIMIT ' . g:sqh_results_limit
        call mysql#ExecuteCommand(query)
    endif
endfunction

"TODO - Is platform agnostic and should not be inthe mysql file.
"Inserts SQL results into a new temporary buffer"
function! mysql#ExecuteCommand(command)
    call sqhell#InsertResultsToNewBuffer('SQHResult', mysql#GetResultsFromQuery(a:command))
endfunction

"TODO - Is platform agnostic and should not be inthe mysql file.
function! mysql#ExecuteBlock() range
    "TODO extract the block selection out so we can test it
    let previous_register_content = @"
    silent! execute a:firstline . ',' . a:lastline . 'y'
    let query = @"
    "Restore whatever was in here back to normal
    let @" = previous_register_content
    call mysql#ExecuteCommand(query)
endfunction

"TODO - Is platform agnostic and should not be inthe mysql file.
"Execute the current line
function! mysql#ExecuteLine()
    call mysql#ExecuteCommand(getline('.'))
endfunction

"TODO - Is platform agnostic and should not be inthe mysql file.
"Execute the given file
function! mysql#ExecuteFile(...)
    let _file = get(a:, 1)

    if a:1 == ''
        let _file = expand('%:p')
    endif

    let file_content = join(readfile(_file), "\n")
    call mysql#ExecuteCommand(file_content)
endfunction

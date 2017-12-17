function! mysql#GetSystemCommand(user, password, host, database, command)
    let l:user = '-u' . a:user . ' '
    let l:password = '-p' . a:password . ' '
    let l:host = '-h' . a:host . ' '
    let l:database = ''

    if a:database !=? ''
        let l:database = '-D' . a:database . ' '
    endif

    return 'mysql --unbuffered ' . l:user . l:password . l:database . l:host . '--table -e ' . shellescape(a:command)
endfunction

function! mysql#GetResultsFromQuery(command)
    let l:user = g:sqh_connections[g:sqh_connection]['user']
    let l:password = g:sqh_connections[g:sqh_connection]['password']
    let l:host = g:sqh_connections[g:sqh_connection]['host']

    "pretty sure we can use get(g:, 'sqh_connections....'
    "instead of this but it will need some execute hackyness probably
    let l:database = ''

    if has_key(g:sqh_connections[g:sqh_connection], 'database')
        let l:database = g:sqh_connections[g:sqh_connection]['database']
    endif

    let l:system_command = mysql#GetSystemCommand(l:user, l:password, l:host, l:database, a:command)
    let l:query_results = system(l:system_command)
    return l:query_results
endfunction

"This is ran when press 'K' on an SQHTable buffer"
function! mysql#DescribeTable(table)
    let l:query = mysql#GetDescribeTableQuery(mysql#GetDatabase(), a:table)
    call sqhell#InsertResultsToNewBuffer('SQHUnspecified', mysql#GetResultsFromQuery(l:query), 1)
endfunction

"This is ran when we press 'e' on an SQHTable buffer
function! mysql#ShowRecordsInTable(table)
    let t:table = a:table
    let l:query = mysql#GetSelectQuery(mysql#GetDatabase(), a:table)
    call sqhell#ExecuteCommand(l:query)
endfunction

function! mysql#ShowDatabases()
    let l:query = mysql#GetShowDatabasesQuery()
    call sqhell#InsertResultsToNewBuffer('SQHDatabase', mysql#GetResultsFromQuery(l:query), 1)
endfunction

"Shows all tables for a given database
"Can also be ran by pressing 'e' in
"an SQHDatabase buffer
function! mysql#ShowTablesForDatabase(database)
    "The entry point and ONLY place w:database should be set"
    let g:sqh_database = a:database
    let l:query = mysql#GetShowTablesQuery(mysql#GetDatabase())
    call sqhell#InsertResultsToNewBuffer('SQHTable', mysql#GetResultsFromQuery(l:query), 1)
endfunction

"Drops database at cursor
"Can also be ran by pressing 'dd' in
"a SQHDatabase buffer
"Arguments:
" - database: string, the database name
" - show: boolean, show databases?
function! mysql#DropDatabase(database, show)
    let l:drop_query = mysql#GetDropDatabaseQuery(a:database)
    let prompt = confirm(sqhell#GeneratePrompt(l:drop_query), "&Yes\n&No", 2)
    if (prompt == 1)
        call mysql#GetResultsFromQuery(l:drop_query)
        if (a:show)
            let l:results = mysql#GetResultsFromQuery(mysql#GetShowDatabasesQuery())
            call mysql#ReloadBuffer(l:results)
        endif
    endif
endfunction

"Returns the last selected database"
function! mysql#GetDatabase()
    return sqhell#TrimString(g:sqh_database)
endfunction

"Returns the last selected table
function! mysql#GetTable()
    return t:table
endfunction

"Drops table by pressing 'dd'
"in a SQHTable buffer
"Arguments:
" - table: string, the table name
" - show: boolean, show databases?
function! mysql#DropTableSQHTableBuf(table, show)
    call mysql#DropTableFromDatabase(mysql#GetDatabase(), a:table, a:show)
endfunction

"Drops table
"Arguments:
" - database: string, the database name
" - table: string, the table name
" - show: boolean, show databases?
function! mysql#DropTableFromDatabase(database, table, show)
    let l:drop_query = mysql#GetDropTableQuery(a:database, a:table)

    let l:prompt = confirm(sqhell#GeneratePrompt(l:drop_query), "&Yes\n&No", 2)

    if (l:prompt == 1)
        call mysql#GetResultsFromQuery(l:drop_query)
        if(a:show)
            let l:results = mysql#GetResultsFromQuery(mysql#GetShowTablesQuery(a:database))
            call mysql#ReloadBuffer(l:results)
        endif
    endif
endfunction

function! mysql#SortResults(sort_options)
    let l:cursor_pos = getpos('.')
    let l:line_until_cursor = getline('.')[:l:cursor_pos[2]]
    let l:sort_column = len(substitute(l:line_until_cursor, '[^|]', '', 'g'))
    if l:sort_column == 0
      let l:sort_column = 1
    endif
    let l:sort_column += 1

    exec '4,$-1!sort -n -k ' . l:sort_column . ' -t \| ' . a:sort_options
    call setpos('.', l:cursor_pos)
endfunction

"Each provider may paste some extra
"crap that is irrelevant to us
"Use this function to customise
"the removal of said crap...
function! mysql#PostBufferFormat()
    keepjumps normal! gg"_2dd
endfunction

"Deletes table row(s) by pressing 'dd'
"in a SQHResult buffer
"Arguments:
" - row: string, the where condition for deleting
function! mysql#DeleteRow()
    let row = mysql#GetColumnValue()
    let attr = mysql#GetColumnName()
    let table = mysql#GetTable()
    let db = mysql#GetDatabase()

    let l:delete_query = mysql#GetDeleteQuery(db, table, attr, row)
    let l:select_query = mysql#GetSelectQuery(db, table)
    let prompt = confirm(sqhell#GeneratePrompt(l:delete_query), "&Yes\n&No", 2)

    if (prompt == 1)
        call mysql#GetResultsFromQuery(l:delete_query)
        let l:results = mysql#GetResultsFromQuery(l:select_query)
        call mysql#ReloadBuffer(l:results)
    endif
endfunction

"Called by pressing 'e' on an SQHResult buffer
function! mysql#EditRow()
    let row = getline('.')
    let csv = sqhell#CreateCSVFromRow(row)
    let savecur = getcurpos()
    let head = mysql#FormatHeadingsAsCsv(mysql#GetTableHeadings())
    call setpos('.', savecur)

    call sqhell#InsertResultsToNewBuffer('SQHInsert', "\n" . head . "\n" . csv, 1)
    let b:type = 'edit'
    let b:prev = csv
endfunction

function! mysql#AddRow()
    if(b:type == 'edit')
        let cols = split(getline(1), ',')
        let vals = getline(2)
        let vals = split(vals, '"')
        let vals = filter(vals, 'v:val != ","')
        let vals = map(vals, '"\"" . v:val . "\""')
        let b:prev = split(b:prev, '"')
        let b:prev = filter(b:prev, 'v:val != ","')
        let b:prev = map(b:prev, '"\"" . v:val . "\""')

        if len(cols) != len(vals)
            echom 'Incorrect number of values.'
            echom 'Expected: ' . len(cols) . ', got: ' . len(vals) . '.'
            return 'Error'
        endif
        let query = mysql#CreateUpdateFromCSV(cols, vals, b:prev)
    elseif(b:type == 'insert')
        "TODO: create insert into query
    endif
    if(query == 'Error')
        return
    endif

    call mysql#GetResultsFromQuery(query)
    let db = mysql#GetDatabase()
    let table = mysql#GetTable()
    let l:results = mysql#GetResultsFromQuery(mysql#GetSelectQuery(db, table))
    call mysql#ReloadBuffer(l:results)
endfunction

function! mysql#ReloadBuffer(content)
    let l:curent_pos = getpos('.')
    :keepjumps normal! ggdG
    :put=a:content
    call mysql#PostBufferFormat()
    call setpos('.', l:curent_pos)
endfunction

"Returns a list of all of the column headings in the current SQHResult
function! mysql#GetTableHeadings()
    let l:line = split(getline(2), '|')
    return map(l:line, 'sqhell#TrimString(v:val)')
endfunction

function! mysql#FormatHeadingsAsCsv(headings)
    return join(a:headings, ',')
endfunction

function! mysql#CreateCSVFromRow(row)
    let l:csv = split(a:row, '|')
    let l:csv = map(l:csv, 'sqhell#TrimString(v:val)')
    let l:csv = map(l:csv, '"\"" . v:val . "\""')
    let l:csv = join(l:csv, ',')
    return l:csv
endfunction

function! mysql#GetColumnName()
    let savecurpos = getcurpos()
    call cursor(1, savecurpos[2])
    let attr = expand('<cword>')
    if attr =~ "^\+-"
        call cursor(2, savecurpos[2])
    endif
    let start = col('.')
    if(getline('.')[col('.')-1] != '|')
        normal! F|
        let start = col('.')
    endif
    normal! f|
    let end = col('.')-2
    let attr = getline('.')[start:end]
    let attr = sqhell#TrimString(attr)
    call setpos('.', savecurpos)
    return attr
endfunction

function! mysql#GetColumnValue()
    let savecurpos = getcurpos()
    let start = col('.')
    if getline('.')[start-1] != '|'
        normal! F|
        let start = col('.')
    endif
    normal! f|
    let end = col('.')-2
    let val = getline('.')[start:end]
    let val = sqhell#TrimString(val)
    call setpos('.', savecurpos)
    return val
endfunction

"====================== Query functions ==============================

function! mysql#GetDescribeTableQuery(database, table)
    let l:query = 'DESCRIBE ' . a:database . '.' . a:table
    return l:query
endfunction

function! mysql#GetSelectQuery(database, table)
    let l:query = 'SELECT * FROM ' . a:database . '.' . a:table . ' LIMIT ' . g:sqh_results_limit
    return l:query
endfunction

function! mysql#GetShowDatabasesQuery()
    let l:query = 'SHOW DATABASES'
    return l:query
endfunction

function! mysql#GetShowTablesQuery(database)
    let l:query = 'SHOW TABLES FROM ' . a:database
    return l:query
endfunction

function! mysql#GetDropDatabaseQuery(database)
    let l:query = 'DROP DATABASE ' . a:database
    return l:query
endfunction

function! mysql#GetDropTableQuery(database, table)
    let l:query = 'DROP TABLE ' . a:database . '.' . a:table
    return l:query
endfunction

function! mysql#GetDeleteQuery(database, table, column, value)
    let l:query = 'DELETE FROM ' . a:database . '.' . a:table . ' WHERE ' . a:column . '=' . "\'" . a:value . "\'"
    return l:query
endfunction

function! mysql#CreateUpdateFromCSV(columns, values, prev_values)
    let assign = ' SET '
    let where = ' WHERE '
    for i in range(0,len(a:columns)-1)
        if(i != 0)
            let assign = assign . ', '
            let where = where . ' AND '
        endif
        let assign = assign . a:columns[i] . '=' . a:values[i]
        let where = where . a:columns[i] . '=' . a:prev_values[i]
    endfor

    let db = mysql#GetDatabase()
    let table = mysql#GetTable()
    let query = 'UPDATE ' . db . '.' . table . assign . where
    return query
endfunction

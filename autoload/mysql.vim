function! mysql#GetResultsFromQuery(command)
    let l:user = g:sqh_connections[g:sqh_connection]['user']
    let l:password = g:sqh_connections[g:sqh_connection]['password']
    let l:host = g:sqh_connections[g:sqh_connection]['host']

    let l:connection_details = 'mysql --unbuffered -u' . l:user . ' -p' . l:password . ' -h' . l:host
    let l:system_command = l:connection_details . ' --table -e ' . shellescape(a:command)
    let l:query_results = system(l:system_command)
    return l:query_results
endfunction

"Tables_in_users_table => users_table"
function! mysql#GetDatabaseName()
    let l:savecur = getcurpos()
    let l:raw_database = split(getline(search('Tables_in_')), 'Tables_in_')[1]
    call setpos('.', l:savecur)
    let l:current_database = substitute(l:raw_database, '|', '', '')
    return l:current_database
endfunction

"This is ran when press 'K' on an SQHTable buffer"
function! mysql#DescribeTable(table)
    let l:db = mysql#GetDatabaseName()
    let l:query = 'DESCRIBE ' . l:db . '.' . a:table
    call sqhell#InsertResultsToNewBuffer('SQHUnspecified', mysql#GetResultsFromQuery(l:query), 1)
endfunction

"This is ran when we press 'e' on an SQHTable buffer
function! mysql#ShowRecordsInTable(table)
    let l:db = sqhell#TrimString(mysql#GetDatabaseName())
    let l:query = 'SELECT * FROM ' . l:db . '.' . a:table . ' LIMIT ' . g:sqh_results_limit
    call sqhell#ExecuteCommand(l:query)
endfunction

function! mysql#ShowDatabases()
    call sqhell#InsertResultsToNewBuffer('SQHDatabase', mysql#GetResultsFromQuery('SHOW DATABASES'), 1)
endfunction

"Shows all tables for a given database
"Can also be ran by pressing 'e' in
"an SQHDatabase buffer
function! mysql#ShowTablesForDatabase(database)
    call sqhell#InsertResultsToNewBuffer('SQHTable', mysql#GetResultsFromQuery('SHOW TABLES FROM ' . a:database), 1)
endfunction

"Drops database at cursor
"Can also be ran by pressing 'dd' in
"a SQHDatabase buffer
"Arguments:
" - database: string, the database name
" - show: boolean, show databases?
function! mysql#DropDatabase(database, show)

    let l:drop_query = 'DROP DATABASE ' . a:database
    let prompt = confirm(sqhell#GeneratePrompt(l:drop_query), "&Yes\n&No", 2)
    if (prompt == 1)
        call mysql#GetResultsFromQuery(l:drop_query)
        if (a:show)
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
    let l:db = mysql#GetDatabaseName()
    call mysql#DropTableFromDatabase(l:db, a:table, a:show)
endfunction

"Drops table
"Arguments:
" - database: string, the database name
" - table: string, the table name
" - show: boolean, show databases?
function! mysql#DropTableFromDatabase(database, table, show)
    let l:drop_query = 'DROP TABLE ' . sqhell#TrimString(a:database) . "." . a:table

    let prompt = confirm(sqhell#GeneratePrompt(l:drop_query), "&Yes\n&No", 2)

    if (prompt == 1)
        call mysql#GetResultsFromQuery(l:drop_query)
        if(a:show)
            :bd
            call sqhell#ShowTablesForDatabase(a:database)
        endif
    endif
endfunction

function! mysql#SortResults(sort_options)
    let cursor_pos = getpos('.')
    let line_until_cursor = getline('.')[:cursor_pos[2]]
    let sort_column = len(substitute(line_until_cursor, '[^|]', '', 'g'))
    if sort_column == 0
      let sort_column = 1
    endif
    let sort_column += 1
    exec '4,$-1!sort -k ' . sort_column . ' -t \| ' . a:sort_options
    call setpos('.', cursor_pos)
endfunction

"Each provider may paste some extra
"crap that is irrelevant to us
"Use this function to customise
"the removal of said crap...
function! mysql#PostBufferFormat()
    normal! gg"_2dd
endfunction

"Deletes table row(s) by pressing 'dd'
"in a SQHResult buffer
"Arguments:
" - row: string, the where condition for deleting
function! mysql#DeleteRow()
    let row = mysql#GetColumnValue()
    let attr = mysql#GetColumnName()
    let list = sqhell#GetTableName()
    let table = list[0]
    let db = list[1]

    let l:delete_query = 'DELETE FROM ' . db . '.' . table . ' WHERE ' . attr . '=' . "\'" . row . "\'"
    let l:select_query = 'SELECT * FROM ' . db . '.' . table . ' LIMIT ' . g:sqh_results_limit
    let prompt = confirm(sqhell#GeneratePrompt(l:delete_query), "&Yes\n&No", 2)

    if (prompt == 1)
        call mysql#GetResultsFromQuery(l:delete_query)
        :bd
        call sqhell#ExecuteCommand(l:select_query)
    endif
endfunction

"Called by pressing 'e' on an SQHResult buffer
function! mysql#EditRow()
    let row = getline('.')
    let csv = sqhell#CreateCSVFromRow(row)
    let savecur = getcurpos()
    let head = mysql#FormatHeadingsAsCsv(mysql#GetTableHeadings())
    call setpos('.', savecur)
    let tmp = split(b:last_query, ' ')
    let index = index(tmp, 'WHERE')
    if(index != -1)
        let tmp = tmp[0:index-1]
    endif
    let index = index(tmp, 'LIMIT')
    if(index != -1)
        let tmp = tmp[0:index-1]
    endif
    let tmp = tmp[len(tmp)-1]
    let tmp = split(tmp, '\.')
    let db = tmp[0]
    let table = tmp[1]

    :bd
    call sqhell#InsertResultsToNewBuffer('SQHInsert', "\n" . head . "\n" . csv, 1)
    let b:type = 'edit'
    let b:prev = csv
    let t:tabInfo = db . '.' . table
endfunction

function! mysql#AddRow()
    if(b:type == 'edit')
        let query = mysql#CreateUpdateFromCSV()
    elseif(b:type == 'insert')
        "TODO: create insert into query
    endif
    if(query == 'Error')
        return
    endif
    :bd
    call mysql#GetResultsFromQuery(query)
    call sqhell#ExecuteCommand('SELECT * FROM ' . t:tabInfo)
    unlet t:tabInfo
endfunction

"Generate the update query from the edited csv style buffer
function! mysql#CreateUpdateFromCSV()
    " Currently the csv is only 2 lines
    " 1st: the table header (to get column names)
    " 2nd: the row to edit
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

    let assign = ' SET '
    let where = ' WHERE '
    for i in range(0,len(cols)-1)
        if(i != 0)
            let assign = assign . ', '
            let where = where . ' AND '
        endif
        let assign = assign . cols[i] . '=' . vals[i]
        let where = where . cols[i] . '=' . b:prev[i]
    endfor

    let query = 'UPDATE ' . t:tabInfo . assign . where
    return query
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

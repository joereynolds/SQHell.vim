function! mysqlQuery#GetDescribeTableQuery(database, table)
    let l:query = 'DESCRIBE ' . a:database . '.' . a:table
    return l:query
endfunction

function! mysqlQuery#GetSelectQuery(database, table)
    let l:query = 'SELECT * FROM ' . a:database . '.' . a:table . ' LIMIT ' . g:sqh_results_limit
    return l:query
endfunction

function! mysqlQuery#GetShowDatabasesQuery()
    let l:query = 'SHOW DATABASES'
    return l:query
endfunction

function! mysqlQuery#GetShowTablesQuery(database)
    let l:query = 'SHOW TABLES FROM ' . a:database
    return l:query
endfunction

function! mysqlQuery#GetDropDatabaseQuery(database)
    let l:query = 'DROP DATABASE ' . a:database
    return l:query
endfunction

function! mysqlQuery#GetDropTableQuery(database, table)
    let l:query = 'DROP TABLE ' . a:database . '.' . a:table
    return l:query
endfunction

function! mysqlQuery#GetDeleteQuery(database, table, column, value)
    let l:query = 'DELETE FROM ' . a:database . '.' . a:table . ' WHERE ' . a:column . '=' . "\'" . a:value . "\'"
    return l:query
endfunction

function! mysqlQuery#CreateUpdateFromCSV()
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

    let db = mysql#GetDatabase()
    let table = mysql#GetTable()
    let query = 'UPDATE ' . db . '.' . table . assign . where
    return query
endfunction

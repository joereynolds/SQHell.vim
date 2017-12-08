function! psql#GetResultsFromQuery(command)
    let user = g:sqh_connections[g:sqh_connection]['user']
    let password = g:sqh_connections[g:sqh_connection]['password']
    let host = g:sqh_connections[g:sqh_connection]['host']
    let db = g:sqh_connections[g:sqh_connection]['database']

    let connection_details = 'PGPASSWORD='. password . ' psql -U' . user . ' -h ' . host . ' -d ' . db
    let system_command = connection_details . " -c " . shellescape(a:command)
    let query_results = system(system_command)
    return query_results
endfunction

function! psql#ShowDatabases()
    let db_query = 'SELECT datname FROM pg_database WHERE datistemplate = false;'
    call sqhell#InsertResultsToNewBuffer('SQHDatabase', psql#GetResultsFromQuery(db_query))
endfunction

function! psql#SortResults(sort_options)
    let cursor_pos = getpos('.')
    let line_until_cursor = getline('.')[:cursor_pos[2]]
    let sort_column = len(substitute(line_until_cursor, '[^|]', '', 'g')) + 1
    exec '3,$!sort -k ' . sort_column . ' -t \| ' . a:sort_options
    call setpos('.', cursor_pos)
endfunction

function! psql#PostBufferFormat()
    keepjumps normal! ggdd
    keepjumps normal! Gdkgg
endfunction


function! psql#GetResultsFromQuery(command)
    let user = g:sqh_connections[g:sqh_connection]['user']
    let password = g:sqh_connections[g:sqh_connection]['password']
    let host = g:sqh_connections[g:sqh_connection]['host']
    let db = g:sqh_connections[g:sqh_connection]['database']

    let connection_details = 'PGPASSWORD='. password . ' psql -U' . user . ' -h ' . host . ' -d ' . db . ' --pset footer'
    let system_command = 'echo ' . shellescape(join(split(a:command, "\n"))) . ' | ' . connection_details
    let query_results = system(system_command)
    return query_results
endfunction

function! psql#ShowDatabases()
    let db_query = 'SELECT datname FROM pg_database WHERE datistemplate = false;'
    call sqhell#InsertResultsToNewBuffer('SQHDatabase', psql#GetResultsFromQuery(db_query))
endfunction

function! psql#SortResults(sort_options)
    if getline(".") =~ '^\s*$'
      echo "Cursor must be within table to sort"
      return
    endif

    let first_line = search('^\s*$', 'bnW') + 3
    let last_line = search('^\s*$', 'nW') - 1

    let cursor_pos = getpos('.')
    let line_until_cursor = getline(first_line)[:cursor_pos[2]]
    let sort_column = len(substitute(line_until_cursor, '[^|]', '', 'g')) + 1

    let sort_command = first_line . ',' . last_line . '!sort -k ' . sort_column . ' -t \| ' . a:sort_options
    exec sort_command
    call setpos('.', cursor_pos)
endfunction

function! psql#PostBufferFormat()
    normal! ggdd
endfunction


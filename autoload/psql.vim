function! psql#GetResultsFromQuery(command)
    let l:user = g:sqh_connections[g:sqh_connection]['user']
    let l:password = g:sqh_connections[g:sqh_connection]['password']
    let l:host = g:sqh_connections[g:sqh_connection]['host']
    let l:db = g:sqh_connections[g:sqh_connection]['database']

    let l:connection_details = 'PGPASSWORD='. l:password . ' psql -U' . l:user . ' -h ' . l:host . ' -d ' . l:db . ' --pset footer'
    let l:system_command = 'echo ' . shellescape(join(split(a:command, "\n"))) . ' | ' . l:connection_details
    let l:query_results = system(l:system_command)
    return l:query_results
endfunction


function! psql#ShowDatabases()
    let db_query = 'SELECT datname FROM pg_database WHERE datistemplate = false;'
    call sqhell#InsertResultsToNewBuffer('SQHDatabase', psql#GetResultsFromQuery(db_query), 1)
endfunction

function! psql#SortResults(sort_options)
    if getline(".") =~ '^\s*$'
      echo "Cursor must be within table to sort"
      return
    endif

    let first_line = search('^\s*$', 'bnW') + 3
    let last_line = search('^\s*$', 'nW') - 1

    let cursor_pos = getpos('.')
    let line_until_cursor = getline(first_line)[:cursor_pos[2] - 1]
    let sort_column = len(substitute(line_until_cursor, '[^|]', '', 'g')) + 1

    let sort_command = first_line . ',' . last_line . '!sort -k ' . sort_column . ' -t \| ' . a:sort_options
    exec sort_command
    call setpos('.', cursor_pos)
endfunction

function! psql#PostBufferFormat()
    keepjumps normal! ggdd
endfunction


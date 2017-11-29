function! psql#GetResultsFromQuery(command)
    let user = g:sqh_connections[g:sqh_connection]['user']
    let password = g:sqh_connections[g:sqh_connection]['password']
    let host = g:sqh_connections[g:sqh_connection]['host']

    let connection_details = 'PGPASSWORD='. password . ' psql -U' . user . ' -h ' . host
    let system_command = connection_details . " -c " . shellescape(a:command)
    let query_results = system(system_command)
    return query_results
endfunction

function! psql#PostBufferFormat()
    normal ggdd
endfunction


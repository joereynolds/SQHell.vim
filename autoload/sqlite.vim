function! sqlite#GetResultsFromQuery(command)
    let l:connection_details = 'sqlite3 -cmd '
    let l:system_command = l:connection_details . shellescape(a:command)
    let l:query_results = system(l:system_command)
    return l:query_results
endfunction

function! sqlite#ShowDatabases()
    call sqhell#InsertResultsToNewBuffer('SQHDatabase', sqlite#GetResultsFromQuery('.databases'), 1)
endfunction

"Each provider may paste some extra
"crap that is irrelevant to us
"Use this function to customise
"the removal of said crap...
function! sqlite#PostBufferFormat()
    keepjumps normal! gg_dd
endfunction

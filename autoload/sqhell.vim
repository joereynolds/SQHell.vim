function! sqhell#GetHost()
    return g:sqh_host
endfunction

function! sqhell#GetUser()
    return g:sqh_user
endfunction

function! sqhell#GetPassword()
    return g:sqh_password
endfunction

function! sqhell#SetHost(host)
    let g:sqh_host = a:host
endfunction

function! sqhell#SetUser(user)
    let g:sqh_user = a:user
endfunction

function! sqhell#SetPassword(password)
    let g:sqh_password = a:password
endfunction

function! sqhell#InsertResultsToNewBuffer(local_filetype, query_results)
    new | put =a:query_results

    "Remove mysql junk"
    "this should probably go into the ftplugin on BufReadPre
    normal gg2dd
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nowrap
    execute 'setlocal filetype=' . a:local_filetype
endfunction

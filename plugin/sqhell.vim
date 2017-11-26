if exists('g:loaded_sqhell')
    finish
endif

let g:loaded_sqhell = 1
let g:sqh_user = get(g:, 'user', '')
let g:sqh_password = get(g:, 'password', '')
let g:sqh_host = get(g:, 'host', '')

function! InsertResultsToNewBuffer(local_filetype, query_results)
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

function! ChangeHost(host)
    let g:sqh_host = a:host
endfunction

function! ChangeUser(user)
    let g:sqh_user = a:user
endfunction

function! ChangePassword(password)
    let g:sqh_password = a:password
endfunction

"Expose our functions for the user
command! -nargs=0 SQHShowDatabases :call mysql#ShowDatabases()
command! -nargs=1 SQHShowTablesForDatabase :call mysql#ShowTablesForDatabase(<q-args>)
command! -nargs=? SQHExecuteFile :call mysql#ExecuteFile(<q-args>)
command! -nargs=1 SQHExecuteCommand :call mysql#ExecuteCommand(<q-args>)
command! -nargs=0 SQHExecuteLine :call mysql#ExecuteLine()
command! -nargs=1 SQHChangeUser :call ChangeUser(<q-args>)
command! -nargs=1 SQHChangeHost :call ChangeHost(<q-args>)
command! -nargs=1 SQHChangePassword :call ChangePassword(<q-args>)

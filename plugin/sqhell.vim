if exists('g:loaded_sqhell')
    finish
endif

let g:loaded_sqhell = 1
let g:sqh_user = get(g:, 'user', '')
let g:sqh_password = get(g:, 'password', '')
let g:sqh_host = get(g:, 'host', '')

command! -nargs=0 SQHShowDatabases :call mysql#ShowDatabases()
command! -nargs=1 SQHShowTablesForDatabase :call mysql#ShowTablesForDatabase(<q-args>)
command! -nargs=? SQHExecuteFile :call mysql#ExecuteFile(<q-args>)
command! -nargs=1 SQHExecuteCommand :call mysql#ExecuteCommand(<q-args>)
command! -nargs=0 SQHExecuteLine :call mysql#ExecuteLine()
command! -nargs=1 SQHSetUser :call sqhell#SetUser(<q-args>)
command! -nargs=1 SQHSetHost :call sqhell#SetHost(<q-args>)
command! -nargs=1 SQHSetPassword :call sqhell#SetPassword(<q-args>)
command! -nargs=1 SQHGetUser :call sqhell#GetUser(<q-args>)
command! -nargs=1 SQHGetHost :call sqhell#GetHost(<q-args>)
command! -nargs=1 SQHGetPassword :call sqhell#GetPassword(<q-args>)

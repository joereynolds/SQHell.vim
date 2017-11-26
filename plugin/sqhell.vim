if exists('g:loaded_sqhell')
    finish
endif

let g:loaded_sqhell = 1
let g:sqh_connection = 'default'

command! -nargs=0 SQHShowDatabases :call mysql#ShowDatabases()
command! -nargs=1 SQHShowTablesForDatabase :call mysql#ShowTablesForDatabase(<q-args>)
command! -nargs=? SQHExecuteFile :call mysql#ExecuteFile(<q-args>)
command! -nargs=1 SQHExecuteCommand :call mysql#ExecuteCommand(<q-args>)
command! -nargs=0 SQHExecuteLine :call mysql#ExecuteLine()
command! -nargs=1 SQHSwitchConnection :call sqhell#SwitchConnection(<q-args>)

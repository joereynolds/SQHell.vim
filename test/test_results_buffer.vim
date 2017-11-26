let v:errors = []

function! Test_results_buffer_sets_the_correct_filetype()
    call sqhell#InsertResultsToNewBuffer('testType', '')
    call assert_equal(&filetype, 'testType')
    quit
endfunction

function! Test_results_buffer_has_correct_local_settings()
    call sqhell#InsertResultsToNewBuffer('testType', '')

    "couldn't test wrap or swapfile they returned 0 no matter what :(
    call assert_equal(&bufhidden, 'hide')
    call assert_equal(&buftype, 'nofile')
    quit
endfunction

function! Test_setting_connection_details_works()
    call sqhell#SetUser('testUser')
    call sqhell#SetPassword('hunter2')
    call sqhell#SetHost('localhost')

    call assert_equal(sqhell#GetPassword(), 'hunter2')
    call assert_equal(sqhell#GetUser(), 'testUser')
    call assert_equal(sqhell#GetHost(), 'localhost')
endfunction

call Test_results_buffer_sets_the_correct_filetype()
call Test_results_buffer_has_correct_local_settings()
call Test_setting_connection_details_works()

echo v:errors

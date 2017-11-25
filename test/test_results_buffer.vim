let v:errors = []

function! Test_results_buffer_sets_the_correct_filetype()
    call InsertResultsToNewBuffer('testType', '')
    call assert_equal(&filetype, 'testType')
    quit
endfunction

function! Test_results_buffer_has_correct_local_settings()
    call InsertResultsToNewBuffer('testType', '')

    "couldn't test wrap or swapfile they returned 0 no matter what :(
    call assert_equal(&bufhidden, 'hide')
    call assert_equal(&buftype, 'nofile')
    quit
endfunction

call Test_results_buffer_sets_the_correct_filetype()
call Test_results_buffer_has_correct_local_settings()
echo v:errors

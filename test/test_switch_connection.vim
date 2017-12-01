let v:errors = []

function! Test_a_warning_is_echoed_if_we_set_an_invalid_host()
    let previous_content = @a

    redir @a
    call sqhell#SwitchConnection('pleb')
    redir end

    "join and split to remove the cruddy \n's"
    let last_message = join(split(@a,"\n"))
    let @a = previous_content

    call assert_match('^\[SQHELL\] host must be one of.*', last_message)

endfunction

call Test_a_warning_is_echoed_if_we_set_an_invalid_host()

echo v:errors

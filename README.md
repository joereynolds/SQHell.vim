# SQHell.vim

An SQL wrapper for Vim.
Currently you can:

- View tables
- View databases
- Describe tables
- Execute arbitrary commands
- View records from a table interactively

NOTE: Currently only MySQL is supported. Support for other DBMS's should be trivial to add but are currently unimplemented.

## Examples

### Execute a command using `SQHExecuteCommand`

![](https://i.imgur.com/AUEhN2C.gif)

### Execute a line using `SQHExecuteLine`

![](https://i.imgur.com/j3m62am.gif)

### Explore the database with buffer aware completions

![](https://i.imgur.com/E12LHnA.gif)

## Installation


### Vim Plug

```
Plug 'joereynolds/SQHell.vim'
```

## Configuration

Connection details will need to be supplied in order for SQHell.vim to connect
to your DBMS of choice.

Example:

```
let g:user = 'root'
let g:password = 'hunter2'
let g:host = 'mydatabaseconnection.office'
```

I **strongly** suggest that the above configuration details are kept *outside*
of version control and gitignored in your global gitignore.

## Tests

Tests are housed in the `test` directory and can be ran by
`vim`ing into the test file and then sourcing the file

i.e.

```
vim test/test_results_buffer.vim
:so %
```

If all tests pass, the `v:errors` array will be empty.
And yes, I plan to improve this.

## What about dbext, vim-sql-workbench and others?

DBExt is very featureful (and very good) but comes in at a whopping 12000 lines
of code. By contrast SQHell.vim is a mere ~100 lines

The setup and installation process for vim-sql-workbench is something that I
aim to avoid with SQHell.vim, ideally a 'set and forget' plugin.

There are no clever inferences inside SQHell.vim.

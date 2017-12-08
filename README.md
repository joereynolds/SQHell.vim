# SQHell.vim

An SQL wrapper for Vim.
Execute commands, sort results, navigate tables and databases and so much more!

The supported providers at the moment are 
- MySQL
- Postgres 

## Examples

(Gifs are using the data from my punk rock band [bogans](http://bogans.uk))
### Execute a command using `SQHExecute!`

Execute a line with `SQHExecute`.

Execute a visual block with `SQHExecute` over a visual selection.

Execute an arbitrary command with `SQHExecute!`.

![](https://i.imgur.com/osjpU6u.gif)

### Execute a file using `SQHExecuteFile`

`SQHExecuteFile` will work on the current buffer if no file is supplied

![](https://i.imgur.com/67nONqC.gif)

### Explore the database with buffer aware mappings

![](https://i.imgur.com/E12LHnA.gif)

## Installation


### Vim Plug

```
Plug 'joereynolds/SQHell.vim'
```

## Configuration

Connection details will need to be supplied in order for SQHell.vim to connect
to your DBMS of choice. The connections are in a dictionary to let you manage
multiple hosts. By default SQHell uses the 'default' key details (no surprise there)

Example:

```
let g:sqh_connections = {
    \ 'default': {
    \   'user': 'root',
    \   'password': 'testing345',
    \   'host': 'localhost'
    \},
    \ 'live': {
    \   'user': 'root',
    \   'password': 'jerw5Y^$Hdfj',
    \   'host': '46.121.44.392'
    \}
\}
```

You can use the `SQHSwitchConnection` function to change hosts.
i.e. `SQHSwitchConnection live`

I **strongly** suggest that the above configuration details are kept *outside*
of version control and gitignored in your global gitignore.

## Default Keybindings

SQHell creates 3 filetypes to make navigation a nicer experience.
These are SQHDatabase, SQHTable, and SQHResult

### SQHDatabase

Inside an SQHDatabase you can press the following

`dd` - Drop the database (don't worry there's a prompt).

`e` - To see all the tables in that database. This will open an SQHTable buffer.


### SQHTable

Inside an SQHDatabase you can press the following

`dd` - Drop the table (don't worry there's a prompt).

`e` - To see all the results for that table with a limit of `g:sqh_results_limit`.
      This will open an SQHResult buffer

### SQHResult

Inside an SQHResult you can press the following

`s` to sort results by the column the cursor is on.

`S` to sort results by the column the cursor is on (in reverse).

`dd` to delete the row WHERE the column is the value under the cursor (don't worry... there's a prompt).

`e` to edit the current row. This will open an SQHInsert buffer.

`i` to insert a new row. This will open an SQHInsert buffer.


### SQHInsert

Inside an SQHInsert you can press the following

`ZZ` to close and save the edited row. This will reopen the previous SQHResult buffer


For more sorting options, you can use `:SQHSortResults` with extra arguments for the unix sort command, a la `:SQHSortResults -rn`. It will always sort by the column the cursor is located on.

## Contributing

Please see the [Contributing guidelines](CONTRIBUTING.md) if you would like to make SQHell even better!

## Tests

Tests use [vader](https://github.com/junegunn/vader.vim).

Tests are housed in the `test` directory and can be ran by
`vim`ing into the test file and running `:Vader`.

## What about dbext, vim-sql-workbench and others?

DBExt is very featureful (and very good) but comes in at a whopping 12000 lines
of code. By contrast SQHell.vim is a mere ~200 lines

The setup and installation process for vim-sql-workbench is something that I
aim to avoid with SQHell.vim, ideally a 'set and forget' plugin.

There are no clever inferences inside SQHell.vim.

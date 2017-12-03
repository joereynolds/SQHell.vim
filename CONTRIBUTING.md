# Contributing

If you want to contribute, thank you!


## Workflow

- Fork the branch
- Work on your fork
- Make sure any changes that affect queries still work with all the commands in `plugin/sqhell.vim`

i.e.
```
SQHShowDatabases
SQHShowTablesForDatabase
SQHExecuteFile
SQHExecute
SQHExecute!
SQHSwitchConnection
SQHDropDatabase
SQHDropTableFromDatabase
```

- If you can, write tests. This will make it easier to prevent regression and make prs quicker as I
  won't have to manually test them
- Add Documentation for what you have added
- Submit the pr

## Guidelines

- Use `normal!` not `normal` to avoid possible mapping conflicts.
- Use `nnoremap` not `nmap` to avoid possible mapping conflicts.
- Use the full name of a vim command where possible, i.e. `setlocal` not `setl`

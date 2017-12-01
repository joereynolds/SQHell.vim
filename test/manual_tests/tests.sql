-- A small set of manual tests to run.

-- Run :SQHExecute over this line without a visual selection. It should run the correct query
SELECT * FROM symfony.gig LIMIT 5

-- Run :SQHExecute over this but with a visual selection. It should run the correct query
-- (badly formatted on purpose)
SELECT
*
FROM
symfony.gig WHERE
YEAR(date) > 2017

-- Run the following commands
-- SQHExecuteCommand SELECT * FROM symfony.gig
-- SQHShowDatabases

-- Run this entire file with
-- SQHExecuteFile

-- Run it as an argument with
-- :SQHExecuteFile /home/joe/.config/nvim/plugged/SQHell.vim/test/manual_tests/tests.sql

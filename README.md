# OracleASHmonitor
Scripts to monitor oracle databases using ASH in real time

These scripts were written based on the first top.sql written by my colleague Amit Spitz which showed a picture of instance activity for 15 minutes 
in terms of a pivot table for average sessions waiting on an event per minute. I extended the basic top to show information in the same format in terms of sql_ids,
module, background process activity, wait class and a couple of other things and also allowing filtering based on module, sql, event. 

The wiki (and comments in scripts) explains in more detail with some example output.

With thanks to Amit for his knowledge, humor and inspiration.

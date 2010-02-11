/ delete data from disk directly, loading one col at a time rather than whole table. Preserves attributes.
/ diskdelete[`:2009.09.09/trade]
/ diskcountdeleted[`:2009.09.09/trade]
/ disksetdeleted[`:2009.09.09/trade;indices]
/ diskgetdeleted[`:2009.09.09/trade]

diskdelete:{[t] / remove records where deleted=1b
	if[0<r:sum deleted:exec deleted from t;
		ii:where not deleted;deleted:0;
		/ rewrite individual columns, do <deleted> last in case we need to recover from half finished run 
		{a:attr v:get y;v:v[x];if[not`=a;v:a#v];y set v;}[ii]each` sv't,'{(x except`deleted),`deleted}get` sv t,`.d];
	(t;r)}

diskgetdeleted:{[t]
	(t;where exec deleted from t)}

diskcountdeleted:{[t]
	(t;exec sum deleted from t)}

disksetdeleted:{[t;ii]
	deleted:exec deleted from t;
	deleted[ii]:1b;
	(` sv t,`deleted)set deleted;
	(t;ii)}

\
/ combining with utilities from dbmaint.q:
/ to add a <deleted> column to all partitions of an existing table 
 addcol[`:db;`trade;`deleted;0b]
/ to cleanup all partitions for a table 
 diskdelete each allpaths[`:db;`trade]
/ then maybe delete the <deleted> column again
 deletecol[`:db;`trade;`deleted]

/ use constraints like:
 select indices:i,date from trade where sym=`AAPL,price=222,time within 08:00 08:15 
 select indices:i by date from trade where sym=`AAPL,price=222,time within 08:00 08:15 
/ to pick out indices per partition to flag deleted 

/ delete data from disk directly, loading one col at a time rather than whole table. Preserves attributes.
/ goes to ridiculous lengths to avoid writing 
/ diskzapdeleted[`:2009.09.09/trade]
/ diskcountdeleted[`:2009.09.09/trade]
/ diskcleardeleted[`:2009.09.09/trade]
/ disksetdeleted[`:2009.09.09/trade;indices]
/ diskgetdeleted[`:2009.09.09/trade]

diskzapdeleted:{[t] / remove records from <t> where deleted=1b
	if[0<r:sum deleted:exec deleted from t;
		ii:where not deleted;deleted:0;
		/ rewrite individual columns, do <deleted> last in case we need to recover from half finished run 
        {a:attr v:get y;v:v[x];if[not`=a;v:a#v];y set v;}[ii]each` sv't,'{x except`deleted}get` sv t,`.d;
        (` sv t,`deleted;17;1;0)set(count ii)#0b];
	(t;r)}

diskgetdeleted:{[t] / get indices (i) in table <t> flagged for deletion
	(t;where exec deleted from t)}

diskcountdeleted:{[t] / number of records in table <t> flagged for deletion  
	(t;exec sum deleted from t)}

disksetdeleted:{[t;ii] / flag indices (i) in table <t> for deletion
	deleted:exec deleted from t;
	if[not all deleted[ii];
		deleted[ii]:1b;
		(` sv t,`deleted;17;1;0)set deleted];
	(t;ii)}

diskcleardeleted:{[t] / unflag/reset deleted flag in table <t>
	if[count ii:where deleted:exec deleted from t;
		deleted[ii]:0b;
		(` sv t,`deleted;17;1;0)set deleted];
	(t;ii)}
\
combining with utilities from dbmaint.q:
to add a <deleted> column to all partitions of table <trade> 
 addcol[`:db;`trade;`deleted;0b]
to cleanup all partitions for table <trade>
 diskzapdeleted each allpaths[`:db;`trade]
then maybe remove the <deleted> column from table <trade> again
 deletecol[`:db;`trade;`deleted]

use constraints like:
 select indices:i,date from trade where sym=`AAPL,price=222,time within 08:00 08:15 
 select indices:i by date from trade where sym=`AAPL,price=222,time within 08:00 08:15 
to pick out indices per partition to flag deleted (disksetdeleted)

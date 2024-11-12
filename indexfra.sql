spool indexfra
set echo on time on timing on
alter index FRA_IDX1 noparallel;
DROP INDEX FRA_IDX1;

CREATE INDEX FRA_IDX1 ON FRA (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text  dataguide off') PARALLEL 4;
alter index FRA_IDX1 noparallel;
select /*+ parallel (d, 8) */ count(1) from fra d;

spool off


spool insertfra_aco
set echo on
alter index FRA_ACO_IDX1 noparallel;
DROP INDEX FRA_ACO_IDX1;

declare
 i number:=0;
 bs number :=1000000;
begin
  for i in 1..20 -- milioni se bs=1E6
  loop
    insert /*+ append parallel*/  into FRA_ACO (id, TIMESTAMPREQUESTUTC, last_modified, version, JSON_DOCUMENT)
    select /*+ parallel (D, 4) */ id, created_on, last_modified, version, JSON_DOCUMENT from "APPL1"."DOCINPS"
    where id between ltrim(to_char((i-1)*bs+1)) and ltrim(to_char(i*bs));
    commit;
    dbms_output.put_line('Batch '||to_char(i)||' completato');
  end loop;
end;
/
    
select /*+ parallel (d, 8) */ count(1) from fra d;
-- serve taaaaanto temp tablespace...
CREATE INDEX FRA_ACO_IDX1 ON FRA_ACO (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text  dataguide off') PARALLEL 4;
alter index FRA_ACO_IDX1 noparallel;
select count(1) from FRA_ACO;

spool off


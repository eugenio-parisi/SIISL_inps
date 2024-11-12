truncate table docinps;
select id_codice_fiscale
	  ,timestampRequestUtc
	  ,timestampRequestUtc
	  ,1
	  from inps_doc_json_v
	  where id_codice_fiscale between 1001 and 1010;
	  
-- spool
spool ricrea_docinps
declare
i number;
batches number := 200;
batchsize number :=100000;
begin
  for i in 1..batches loop 
	  insert /*+ APPEND PARALLEL (4) */ into docinps 
	  (ID
	  ,CREATED_ON
	  ,LAST_MODIFIED
	  ,VERSION
	  ,JSON_DOCUMENT)
	  select id_codice_fiscale
	  ,timestampRequestUtc
	  ,timestampRequestUtc
	  ,1
	  ,JSON_DOCUMENT
	  from inps_doc_json_v
	  where id_codice_fiscale between ((i-1)*batchsize+1) and i*batchsize;
	  dbms_output.put_line(to_char(i));
	  commit;
  end loop;
  dbms_output.put_line('fatto');
end;
/
select count(1) from docinps;

-- con docinps
-- serve indice on in-memory.
--DROP INDEX docinps_IDX1 force;
spool ricrea_indice
alter index docinps_IDX1 noparallel;
DROP INDEX docinps_IDX1;
-- serve taaaaanto temp tablespace...
CREATE INDEX docinps_IDX1 ON docinps (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text_value dataguide off') PARALLEL 2;
alter index docinps_IDX1 noparallel;
select count(1) from docinps;
select codice_fiscale from codice_fiscale where id=1000000;
spool off

spool ricrea_indice
-- text e non text_value
alter index docinps_IDX1 noparallel;
DROP INDEX docinps_IDX1;
-- serve taaaaanto temp tablespace...
CREATE INDEX docinps_IDX1 ON docinps (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text  dataguide off') PARALLEL 4;
alter index docinps_IDX1 noparallel;
select count(1) from docinps;
select codice_fiscale from codice_fiscale where id=1000000;
spool off


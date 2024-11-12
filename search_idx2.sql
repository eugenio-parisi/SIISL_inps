DECLARE
  spec    VARCHAR2(700);
  coll    SODA_Collection_T;
  status  NUMBER;
BEGIN
  coll := dbms_soda.open_Collection('TB_METrF_TransactionalFlow_CL');
/*
  spec := '{
            "name": "SEARCH_IDX",
            "dataguide": "off",
            "search_on": "text"
           }';
*/
  status := coll.drop_Index('SEARCH_IDX');
  execute immediate 'ù
	CREATE INDEX docinps_IDX1 ON docinps (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS (''SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") 
optimize (auto_daily) dataguide off'') ;';
--  status := coll.create_Index(spec);
END;
/

DECLARE
  spec    VARCHAR2(700);
  coll    SODA_Collection_T;
  status  NUMBER;
BEGIN
  coll := dbms_soda.open_Collection('TB_METrF_TransactionalFlow_CL');
  spec := '{
            "name": "SEARCH_IDX",
            "dataguide": "off",
            "search_on": "text"
           }';
  status := coll.drop_Index('SEARCH_IDX');
  status := coll.create_Index(spec);
END;
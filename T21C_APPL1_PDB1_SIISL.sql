select * from dba_data_Files;
select * from dba_temp_Files;
select * from dba_tablespaces;
alter database tempfile 4 autoextend on next 1g maxsize unlimited;
alter tablespace temp add tempfile size 1g autoextend on next 1g maxsize unlimited;

/*
Customer: INPS (equivalent of SSA in the US).
New project initially targeted to mongodb: we convinced to use Oracle 21c 
App design is: collect all retirement ("Pension") requests in a single hub (e.g.,
a *single* JSON collection) and search among those.
They have quite a big collection (3000000+ docs) thus they would like to query using indexes. 

Example JSON docs: pls see attached files "sample{1-6].json" in "samples.zip".

JSON docs contain some special attribute, the "Codice Fiscale" (en translation:==fiscal code, abbrev is "cf").
"cf" is a natural key for data in Italy, both for a company and a person; for Pensions, Tolls, ...

Our collection is called "TB_METrF_TransactionalFlow_CL" so the aim is to query this
collection with a QBE filter in this way:
- always put the <request timestamp UTC> attribute in a "$between" filter
  (or logically the same with a "<= and >=" filter). Attribute name 
  is "timestampRequestUtc"
- "match" a single cf (the searched cf) in various part of the JSON doc, e.g. "request.codiceFiscale"
  - including sub paths
  - including arrays
  - including arrays of arrays
- btw not in all parts: e.g., don't match other cf's in all possible attributes (in a different path), 
  since they have different meaning (for e.g. thea person leaving in the same family, 
  the requestor of another instance etc.)

This a quite complex QBE they would like to use:
{"$query":
 {"$and": 
  [
   {"timestampRequestUtc":
     { "timestampRequestUtc":{ "$between": ["2023-01-01T00:00:00.0000000", "2024-12-31T00:00:00.0000000"] } }
    ,{"$or":
      [
         {"request.codiceFiscale": "BNCGVN55D70D460A"}
        ,{"request.cfTut_AMM_RL": "BNCGVN55D70D460A"}
        ,{"request.codiceFiscaleRichiedente": "BNCGVN55D70D460A"}
        ,{"request.informazioniDid.codiceFiscale": "BNCGVN55D70D460A"}
        ,{"request.cfRichiedente": "BNCGVN55D70D460A"}
        ,{"request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cf": "BNCGVN55D70D460A"}
        ,{"request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cfCollegato[*]": "BNCGVN55D70D460A"}
        ,{"request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore": "BNCGVN55D70D460A"}
        ,{"request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente": "BNCGVN55D70D460A"}
        ,{"request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cf": "BNCGVN55D70D460A"}
        ,{"request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cfCollegato[*]": "BNCGVN55D70D460A"}
        ,{"request.estremiDomanda.datiTutore.cfTutore": "BNCGVN55D70D460A"}
        ,{"request.estremiDomanda.datiRichiedente.cfRichiedente": "BNCGVN55D70D460A"}
        ,{"request.codiceFiscaleBeneficiario": "BNCGVN55D70D460A"}
        ,{"response.payload.lavoratore.datiAnagrafici.codiceFiscale": "BNCGVN55D70D460A"}
      ]
     }
  ]
 }
}

As you can see:
- most of cf dealt with are in the "request" path
- only one is under the "response" path
- no other path are actually searched (btw they contain various other cf in various paths)

Pls note: ct tried with:
- a normal index: got ORA-40462: JSON_VALUE evaluated to no value
- a search index: that is ok btw it matches the entire doc not a specific 
  path attribute and sometimes hit limitations ORA-40676)

I reported on both the ORA-40462 and ORA-40676 issues, along with limitations on searching 
in arrays in slack here:
  https://sales-emea-japac.slack.com/archives/C01B6HBM4GH/p1706718256659679
 
Let's step back to our QBE's or-ed filters:
*         {"request.codiceFiscale": "BNCGVN55D70D460A"}
*        ,{"request.cfTut_AMM_RL": "BNCGVN55D70D460A"}
*        ,{"request.codiceFiscaleRichiedente": "BNCGVN55D70D460A"}
*        ,{"request.informazioniDid.codiceFiscale": "BNCGVN55D70D460A"}
*        ,{"request.cfRichiedente": "BNCGVN55D70D460A"}
**       ,{"request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cf": "BNCGVN55D70D460A"}
***      ,{"request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cfCollegato[*]": "BNCGVN55D70D460A"}
*        ,{"request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore": "BNCGVN55D70D460A"}
*        ,{"request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente": "BNCGVN55D70D460A"}
**       ,{"request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cf": "BNCGVN55D70D460A"}
***     ,{"request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cfCollegato[*]": "BNCGVN55D70D460A"}
*        ,{"request.estremiDomanda.datiTutore.cfTutore": "BNCGVN55D70D460A"}
*        ,{"request.estremiDomanda.datiRichiedente.cfRichiedente": "BNCGVN55D70D460A"}
*        ,{"request.codiceFiscaleBeneficiario": "BNCGVN55D70D460A"}
*        ,{"response.payload.lavoratore.datiAnagrafici.codiceFiscale": "BNCGVN55D70D460A"}

FIlters belong to these sets (in my understanding):
- set *:   search for a scalar in *one* specific object field. Field is never a top field
- set **:  search for a scalar in *one* specific object field (or member) in an array of objects
- set ***: search for a scalar in any field of an array of arrays of objects
pls note: words "field","array","object","member","scalar" are intened to have the meaning reported here:
"1.2 JSON Syntax and the Data It Represents":
  https://docs.oracle.com/en/database/oracle/oracle-database/21/adjsn/json-data.html#GUID-FBC22D72-AA64-4B0A-92A2-837B32902E2C

In my understanding these sentences are true:
s1 - set * filters: can be always searched (JSON_TEXTCONTAINS in SQL -- $contains in SODA -- and single- or multi-value indexes ) 
   - set ** filters: can be searched 
s2 - only using $contains or JSON_TEXTCONTAINS: no single- or multivalue indexes.
s3 - only to the last non-array step as reported here (this time I'm taking 23c doc):
     JSON_TEXTCONTAINS Condition
     https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/SQL-JSON-Conditions.html#GUID-DEF7941B-1267-44E7-8514-5CD448503179
     The path expression can contain only JSON object steps; it cannot contain JSON array steps.
     Furtherly:
     - in SQL: JSON_TEXTCONTAINS always work
     - in SODA: there is a subsequent limitation:
       5.2.7.2 Contains Clause (Reference) 
       https://docs.oracle.com/en/database/oracle/simple-oracle-document-access/adsdi/soda-filter-specifications-reference.html#GUID-C4C426FC-FD23-4B2E-8367-FA5F83F3F23A
       and I got that it's the same in 23c, btw it could be release -- may be via an Enh.Req, I don't kno. 
s4 - set *** filters: as above but for same reasons:
s5   they can find ghe "cf" in the wrong field

Now: am I wrong on sentence s2? You wrote:
"are they using json search index just because values can be arrays? 
If that’s the case, since they are using 21c, mutli-value index might work.
Will need to check whether these filters pickup multi-value index in 21c, 
in which case they might not need an enhancement in filters and wouldn’t need to use $contains. 
Answer is: thwy would like to search data attached here in the way I explained.
They finally gave me the data and the code they used for a testcase.
I ran the testcase on a 21c instance and their code snippets work as expected.
*/

-- re-create the collection -- questa solo in SQLcl     
soda drop TB_METrF_TransactionalFlow_CL
soda create TB_METrF_TransactionalFlow_CL
desc "TB_METrF_TransactionalFlow_CL"
soda list

--
SELECT T.* FROM "TB_METrF_TransactionalFlow_CL" T;
--

-------- Create an index
-- this tries to create a standard index
-- but fails with: ORA-40462: JSON_VALUE evaluated to no value
DECLARE
  spec    VARCHAR2(700);
  coll    SODA_Collection_T;
  status  NUMBER;
BEGIN
  coll := dbms_soda.open_Collection('TB_METrF_TransactionalFlow_CL');
  spec := '{"name"   : "CF_IDX1",
            "unique" : false,
            "indexNulls": false,
            "lax": false,
            "scalarRequired": true,  
            "fields" : [{ "path": "request.codiceFiscale", "datatype": "string" }]
           }';
  status := coll.drop_Index('CF_IDX1');
  status := coll.create_Index(spec);
END;
/

-- This creates a JSON search index: this is currently ct's w/a
DECLARE
    collection  SODA_COLLECTION_T;
    indexSpec        VARCHAR2(700);
    status      NUMBER;
BEGIN
    -- Open the collection
    collection := DBMS_SODA.open_collection('TB_METrF_TransactionalFlow_CL');
    
    -- Define the index specification
    /* this is a search index */
    indexSpec := '{"name" : "CF_IDX1",'||
                '"dataguide" : "off",'||
                '"search_on" : "text_value"}'; 
               
    -- drop the index
    status := collection.drop_index('CF_IDX1');
    dbms_output.put_line('index dropped');
    DBMS_OUTPUT.put_Line('Status: ' || status);

    -- Create the index
    status := collection.create_index(indexSpec);
    dbms_output.put_line('index created');
    DBMS_OUTPUT.put_Line('Status: ' || status);
END;
/

------ PL/SQL Testcase to see if an index is used or not
-- this queries the collection via QBE. It finds (using attached sample data, exaclty one document of the collection)
DECLARE
    vr_arr_list KU$_VCNT := KU$_VCNT();
    collection SODA_COLLECTION_T;
    document SODA_DOCUMENT_T;
    cur SODA_CURSOR_T;
    status BOOLEAN;
    counter int := 0;
    cf varchar(255) := 'BNCGVN55D70D460A'; 
    qbe varchar(4000) := '
{"$query":
 {"$and": 
  [
     { "timestampRequestUtc":{ "$between": ["2023-01-01T00:00:00.0000000", "2024-12-31T00:00:00.0000000"] } }
    ,{"$or":
      [
       {"request.codiceFiscale": "'||cf||'"}
      ,{"request.cfTut_AMM_RL": "'||cf||'"}
      ,{"request.codiceFiscaleRichiedente": "'||cf||'"}
      ,{"request.informazioniDid.codiceFiscale": "'||cf||'"}
      ,{"request.cfRichiedente": "'||cf||'"}
      ,{"request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cf": "'||cf||'"}
      ,{"request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cfCollegato[*]": "'||cf||'"}
      ,{"request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore": "'||cf||'"}
      ,{"request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente": "'||cf||'"}
      ,{"request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cf": "'||cf||'"}
      ,{"request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cfCollegato[*]": "'||cf||'"}
      ,{"request.estremiDomanda.datiTutore.cfTutore": "'||cf||'"}
      ,{"request.estremiDomanda.datiRichiedente.cfRichiedente": "'||cf||'"}
      ,{"request.codiceFiscaleBeneficiario": "'||cf||'"}
      ,{"response.payload.lavoratore.datiAnagrafici.codiceFiscale": "'||cf||'"}
      ]
     }
  ]
 }
}';
  i number:=0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Start : '||SYSTIMESTAMP);
    collection := DBMS_SODA.open_collection('TB_METrF_TransactionalFlow_CL');
    cur := collection
    .find()
    .filter(qbe)
    .get_cursor();
    DBMS_OUTPUT.PUT_LINE('Phase 1 Start : '||SYSTIMESTAMP);
    WHILE cur.has_next LOOP
        document := cur.next;
        IF document IS NOT NULL THEN
            counter := counter + 1;
            vr_arr_list.extend();
            vr_arr_list(counter) := document.get_key;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Phase 1 End : '||SYSTIMESTAMP);
    status := cur.close;
    i:=vr_arr_list.count;
        if i>0 then
          DBMS_OUTPUT.PUT_LINE(to_char(i)||' document(s) found!');
        else
          DBMS_OUTPUT.PUT_LINE('No document found!');
        end if;
    --DBMS_OUTPUT.PUT_LINE('Print results Start : '||SYSTIMESTAMP);
    FOR myrec in (SELECT T.* FROM "TB_METrF_TransactionalFlow_CL" T WHERE T.ID MEMBER OF vr_arr_list)
    loop
        DBMS_OUTPUT.PUT_LINE('Id: '||myrec.id);
    end loop;
    --DBMS_OUTPUT.PUT_LINE('Print results End: '||SYSTIMESTAMP);
    DBMS_OUTPUT.PUT_LINE('End: '||SYSTIMESTAMP);
END;
/


-- 12-jul-2024
-- prova su una nuova collection: ASISPCMDB, creata con dati fake -- oltre 300k docs
soda list collections;

SELECT * FROM ASISPCMDB
WHERE
    ( ( JSON_VALUE("DATA", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("DATA", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      --AND ( JSON_TEXTCONTAINS ( "DATA", '$', 'XXXXXX72B14F839F' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfTut_AMM_RL', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.informazioniDid.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CFRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleBeneficiario', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.ComponenteFamiliare_CF', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscaleRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleInadempiente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscaleAggiornato', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'XXXXXX72B14F839F' ) 
          )
    );

select count(1) from ASISPCMDB;
select * from  V$IM_SEGMENTS where segment_name='ASISPCMDB';
select bytes/1024/1024/1024 gib from user_segments where segment_name='ASISPCMDB';

-- prova su una nuova collection: ASISPCMDB, creata con dati fake -- oltre 300k docs
select count(1) from (
SELECT * FROM ASISPCMDB
WHERE
    ( ( JSON_VALUE("DATA", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("DATA", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      --AND ( JSON_TEXTCONTAINS ( "DATA", '$', 'XXXXXX72B14F839F' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfTut_AMM_RL', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.informazioniDid.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CFRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleBeneficiario', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.ComponenteFamiliare_CF', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscaleRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleInadempiente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscaleAggiornato', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'XXXXXX72B14F839F' ) 
          )
    )
);

-- 25-jul-2024
-- Fra creata vuota con Compass
-- inserita con i dati del mio piccolo testcase realizzato per Maxim O dalla collection APPL1."TB_METrF_TransactionalFlow_CL" 
-- aggiunta con i dati avuti da Francesco e già inseriti in ASISPCMDB

desc "Fra";
soda list
select count(1) from "Fra";
/*
COUNT(1) 
-------- 
  356589
*/

-- questa va inmemory causa autoinmo
select * from  V$IM_SEGMENTS where segment_name='Fra';

/*
OWNER SEGMENT_NAME PARTITION_NAME SEGMENT_TYPE TABLESPACE_NAME INMEMORY_SIZE      BYTES BYTES_NOT_POPULATED POPULATE_STATUS INMEMORY_PRIORITY INMEMORY_DISTRIBUTE INMEMORY_DUPLICATE INMEMORY_COMPRESSION INMEMORY_SERVICE INMEMORY_SERVICE_NAME IS_EXTERNAL CON_ID 
----- ------------ -------------- ------------ --------------- ------------- ---------- ------------------- --------------- ----------------- ------------------- ------------------ -------------------- ---------------- --------------------- ----------- ------ 
APPL1 Fra                         TABLE        USERS              1166671872 1202814976                   0 COMPLETED       NONE              AUTO                NO DUPLICATE       AUTO                 DEFAULT                                FALSE            3 


Elapsed: 00:00:00.001
1 rows selected.
*/
select bytes/1024/1024/1024 gib from user_segments where segment_name='Fra';
/*
  GIB 
----- 
1.125 
*/

-- prova sulla nuova collection Fra, con i Fake più qualche dato più selettivo -- quasy 400k docs
-- da errore vedi sotto -- con ASISPCMDB non mi sembra che lo desse....
SELECT * FROM "Fra"
WHERE 
    ( ( JSON_VALUE("DATA", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("DATA", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      --AND ( JSON_TEXTCONTAINS ( "DATA", '$', 'BNCGVN55D70D460A' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfTut_AMM_RL', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.informazioniDid.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CFRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiTutore.cfTutore', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleBeneficiario', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.ComponenteFamiliare_CF', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscaleRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleInadempiente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscaleAggiornato', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'BNCGVN55D70D460A' ) 
          )
    )
;
-- errore:
/*
40467. 00000 -  "JSON_TEXTCONTAINS() cannot be evaluated without a JSON-enabled context index"
*Cause:    There was no JavaScript Object Notation (JSON)-enabled context
           index available.
*Action:   Create a JSON-enabled context index.
Error at Line: 1 Column: 13
*/

-- crea l'indice
DROP INDEX FRA_IDX1;
CREATE INDEX FRA_IDX1 ON "Fra" 
    ( 
     DATA 
    ) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (on commit) search_on text_value dataguide off') 
;

/* reverse DDL:
CREATE SEARCH INDEX FRA_IDX1 ON "Fra" (DATA) FOR JSON PARAMETERS ('DATAGUIDE OFF');
*/

/* -- no parallel+recovery: lento
Index FRA_IDX1 created.

Elapsed: 00:05:49.343
*/

-- prova di nuovo 
--select count(1) from (
SELECT * FROM "Fra"
WHERE 
    ( ( JSON_VALUE("DATA", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("DATA", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      --AND ( JSON_TEXTCONTAINS ( "DATA", '$', 'BNCGVN55D70D460A' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfTut_AMM_RL', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.informazioniDid.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CFRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiTutore.cfTutore', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleBeneficiario', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.ComponenteFamiliare_CF', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscaleRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleInadempiente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscaleAggiornato', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'BNCGVN55D70D460A' ) 
          )
    )
--)
;
--> 1"


-- prova con la clausola pleonastica:
SELECT * FROM "Fra"
WHERE 
    ( ( JSON_VALUE("DATA", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("DATA", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      AND ( JSON_TEXTCONTAINS ( "DATA", '$', 'BNCGVN55D70D460A' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfTut_AMM_RL', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.informazioniDid.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CFRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiTutore.cfTutore', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleBeneficiario', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.ComponenteFamiliare_CF', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscaleRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleInadempiente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscaleAggiornato', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'BNCGVN55D70D460A' ) 
          )
    )
;
--> 3" (forse agisce InMemory)


-- prova con la clausola pleonastica e specifica no_inmemory
SELECT /*+ no_inmemory */ * FROM "Fra"
WHERE 
    ( ( JSON_VALUE("DATA", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("DATA", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      AND ( JSON_TEXTCONTAINS ( "DATA", '$', 'BNCGVN55D70D460A' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfTut_AMM_RL', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.informazioniDid.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CFRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiTutore.cfTutore', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleBeneficiario', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.ComponenteFamiliare_CF', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscaleRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleInadempiente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscaleAggiornato', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'BNCGVN55D70D460A' ) 
          )
    )
;

-- calcola le statistiche
exec dbms_stats.gather_table_stats('','"Fra"');

-- prova con la clausola pleonastica e specifica no_inmemory
SELECT /*+ no_inmemory */ * FROM "Fra"
WHERE 
    ( ( JSON_VALUE("DATA", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("DATA", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      AND ( JSON_TEXTCONTAINS ( "DATA", '$', 'BNCGVN55D70D460A' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfTut_AMM_RL', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.informazioniDid.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CFRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiTutore.cfTutore', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'BNCGVN55D70D460A')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleBeneficiario', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.ComponenteFamiliare_CF', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscaleRichiedente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleInadempiente', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscale', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscaleAggiornato', 'BNCGVN55D70D460A' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'BNCGVN55D70D460A' ) 
          )
    )
;

--> 1"
-- prova sul cf mascherato con clausola
SELECT * FROM "Fra"
WHERE
    ( ( JSON_VALUE("DATA", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("DATA", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      AND ( JSON_TEXTCONTAINS ( "DATA", '$', 'XXXXXX72B14F839F' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfTut_AMM_RL', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.informazioniDid.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CFRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleBeneficiario', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.ComponenteFamiliare_CF', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscaleRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleInadempiente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscaleAggiornato', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'XXXXXX72B14F839F' ) 
          )
    )
;

-- prova sul cf mascherato senza clausola
SELECT * FROM "Fra"
WHERE
    ( ( JSON_VALUE("DATA", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("DATA", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      AND ( JSON_TEXTCONTAINS ( "DATA", '$', 'XXXXXX72B14F839F' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfTut_AMM_RL', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.informazioniDid.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.cfRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CFRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'XXXXXX72B14F839F')
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleBeneficiario', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.ComponenteFamiliare_CF', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.CodiceFiscaleRichiedente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.codiceFiscaleInadempiente', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscale', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.request.anagrafica.codiceFiscaleAggiornato', 'XXXXXX72B14F839F' )
              OR JSON_TEXTCONTAINS ( "DATA", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'XXXXXX72B14F839F' ) 
          )
    )
;



-- compressa HCC
select bytes/1024/1024/1024 gib from user_segments where segment_name='Fra';
drop table FRA_HCC purge;
create table FRA_HCC as select * from "Fra";
select bytes/1024/1024/1024 gib from user_segments where segment_name='FRA_HCC';
alter table FRA_HCC move compress for query high; -- non funziona ci vuole un evento.
--- SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

select bytes/1024/1024 mib from user_segments where segment_name='FRA_HCC';
-- 0.05

-- aggiunta della colonna virtuale 
select MIN(JSON_VALUE("DATA" FORMAT JSON, '$.timestampRequestUtc' RETURNING TIMESTAMP NULL ON ERROR)) mintstamp, MIN(JSON_VALUE("DATA" FORMAT JSON, '$.timestampRequestUtc' RETURNING TIMESTAMP NULL ON ERROR)) maxtstamp from fra_hcc;
alter table FRA_HCC add (timestampRequestUtc TIMESTAMP GENERATED ALWAYS AS (JSON_VALUE("DATA" FORMAT JSON , '$.timestampRequestUtc' RETURNING TIMESTAMP NULL ON ERROR)) VIRTUAL);
desc FRA_HCC
select min(TIMESTAMPREQUESTUTC) mints, max(TIMESTAMPREQUESTUTC) maxts from fra_hcc;
select to_char(TIMESTAMPREQUESTUTC,'YYYYMM'), count(*) from fra_hcc /*where rownum<=100 */ group by to_char(TIMESTAMPREQUESTUTC,'YYYYMM');
select avg(docs) from (select to_char(TIMESTAMPREQUESTUTC,'YYYYMM'), count(*) docs from fra_hcc /*where rownum<=100 */ group by to_char(TIMESTAMPREQUESTUTC,'YYYYMM'));

select count(1) from fra_hcc where TIMESTAMPREQUESTUTC is null;
select count(1) from fra_hcc;
-- END FRA_HCC

-- FRA --
SELECT /*+ MONITOR GATHER_PLAN_STATISTICS */ * FROM "Fra" 
WHERE JSON_VALUE(DATA, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(DATA, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
AND JSON_TEXTCONTAINS(DATA, '$', 'DMRPQL73S20F839M')
AND (
	JSON_TEXTCONTAINS(DATA, '$.request.codiceFiscale', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.cfTut_AMM_RL', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.codiceFiscaleRichiedente', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.informazioniDid.codiceFiscale', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.cfRichiedente', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.CFRichiedente', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.estremiDomanda.datiTutore.cfTutore', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.codiceFiscaleBeneficiario', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.CodiceFiscale', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.ComponenteFamiliare_CF', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.CodiceFiscaleRichiedente', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.codiceFiscaleInadempiente', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.anagrafica.codiceFiscale', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.request.anagrafica.codiceFiscaleAggiornato', 'DMRPQL73S20F839M')
	OR JSON_TEXTCONTAINS(DATA, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'DMRPQL73S20F839M')
);

        SELECT /*+ NO_MERGE(v2) */ *
        FROM (
                SELECT /*+ NO_MERGE(v)  */ *
                FROM 
                (
                    SELECT DATA        
                    FROM "Fra" F 
                    WHERE JSON_TEXTCONTAINS (F."DATA", '$', 'XXXXXX72B14F839F')
                ) v
                WHERE 
                    (
                           JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscale', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.cfTut_AMM_RL', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleRichiedente', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.informazioniDid.codiceFiscale', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.cfRichiedente', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.CFRichiedente', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleBeneficiario', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.CodiceFiscale', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.ComponenteFamiliare_CF', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.CodiceFiscaleRichiedente', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleInadempiente', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.anagrafica.codiceFiscale', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.request.anagrafica.codiceFiscaleAggiornato', 'XXXXXX72B14F839F')
                        OR JSON_TEXTCONTAINS(v.DATA, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'XXXXXX72B14F839F')
                    )
            ) v2
        WHERE JSON_VALUE(v2.DATA, '$.timestampRequestUtc') between '1970-01-01T00:00:00.0000000' and '9999-12-31T00:00:00.0000000'     
; 

-- FRA --



-- FRA_ACO -- compressa ACO.
-- prende i metadati da una collection di esempio creata con soda create solo per risparmiare tempo
set serverout on
DECLARE
    collection  SODA_COLLECTION_T;
BEGIN
    collection := DBMS_SODA.open_collection('ttt');
    IF collection IS NULL THEN
        DBMS_OUTPUT.put_line('Collection does not exist');
    ELSE
        DBMS_OUTPUT.put_line('Metadata: '
                             || json_query(collection.get_metadata, '$' PRETTY));
    END IF;
END;
/

-- mettere qui il risultato
/*
Metadata: {
  "schemaName" : "APPL1",
  "tableName" : "TTT",
  "keyColumn" :
  {
    "name" : "ID",
    "sqlType" : "VARCHAR2",
    "maxLength" : 255,
    "assignmentMethod" : "UUID"
  },
  "contentColumn" :
  {
    "name" : "JSON_DOCUMENT",
    "sqlType" : "JSON"
  },
  "lastModifiedColumn" :
  {
    "name" : "LAST_MODIFIED"
  },
  "versionColumn" :
  {
    "name" : "VERSION",
    "method" : "UUID"
  },
  "creationTimeColumn" :
  {
    "name" : "CREATED_ON"
  },
  "readOnly" : false
}
*/

set serverout on
declare
r number:=0;
begin
r:=DBMS_SODA.drop_collection(collection_name=>'FRA_ACO', purge=>true, drop_mapped_table=>true);
IF r>0 THEN
    DBMS_OUTPUT.put_line('Collection dropped');
ELSE
    DBMS_OUTPUT.put_line('Collection does not exist');
END IF;
end;
/

DECLARE
    collection SODA_COLLECTION_T;
    metadata VARCHAR2(4000) :=  '{"creationTimeColumn": {"name" : "TIMESTAMPREQUESTUTC" }, "lastModifiedColumn" : { "name" : "LAST_MODIFIED"}, "versionColumn" : {"name" : "VERSION", "method" : "UUID" } }';
BEGIN
    collection := DBMS_SODA.create_collection('FRA_ACO', metadata);
    DBMS_OUTPUT.put_line ('Collection specification: ' ||json_query(collection.get_metadata, '$' PRETTY));
END;
/

-- la collection non è partizionata né compressa (in alcuna sua parte)
desc FRA_ACO
-- aggiunge la compressione ACO sulle colonne standard (e non sul JSON)
ALTER TABLE "APPL1"."FRA_ACO_PART" ROW STORE COMPRESS ADVANCED;

-- aggiunge in-memory sul JSON
-- ALTER TABLE "APPL1"."FRA_ACO_PART"  INMEMORY TEXT (JSON_DOCUMENT);

-- specifica la compressione per il JSON
ALTER TABLE "APPL1"."FRA_ACO_PART" move  ("JSON_DOCUMENT") (compress low);



drop table FRA_ACO purge;
CREATE TABLE "APPL1"."FRA_ACO"
   ("ID" VARCHAR2(255 BYTE), 
	"TIMESTAMPREQUESTUTC" TIMESTAMP (6), 
	"LAST_MODIFIED" TIMESTAMP (6), 
	"VERSION" VARCHAR2(255 BYTE), 
	"JSON_DOCUMENT" JSON
   ) SEGMENT CREATION IMMEDIATE 
ROW STORE COMPRESS ADVANCED
LOGGING
INMEMORY TEXT (JSON_DOCUMENT);

-- come si fa la compressione ? Chiesto su slack.
alter table FRA_ACO move json(c1) store as (compress low);

DECLARE
    collection SODA_COLLECTION_T;
    metadata VARCHAR2(4000) :=  '{"creationTimeColumn": {"name" : "TIMESTAMPREQUESTUTC" }, "lastModifiedColumn" : { "name" : "LAST_MODIFIED"}, "versionColumn" : {"name" : "VERSION", "method" : "UUID" } }';
BEGIN
    collection := DBMS_SODA.create_collection('FRA_ACO', metadata, DBMS_SODA.CREATE_MODE_MAP);
    DBMS_OUTPUT.put_line ('Collection specification: ' ||json_query(collection.get_metadata, '$' PRETTY));
END;
/




drop table test_explain purge;
create table test_explain (EXPLAIN_ID 	 VARCHAR2(30)
,ID 	 NUMBER 	
,PARENT_ID 	 NUMBER
,OPERATION 	 VARCHAR2(30)
,OPTIONS 	 VARCHAR2(30)
,OBJECT_NAME 	 VARCHAR2(80)
,POSITION 	 NUMBER
,CARDINALITY 	 NUMBER);


-- AGOSTO 2024: WA NOMERGE: la clausola pleonastica non funziona in INPS

-- nomerge test semplice: usa NL Per scandire tutti i risultati di V -- che sono i soli doc che hanno quel CF all'interno, dovunque
-- nel mio caso, va in NL (sui 20kdocs!)
SELECT /*+ NO_MERGE(v) */ * 
from "Fra" F1, (SELECT F2.id FROM "Fra" F2 WHERE JSON_TEXTCONTAINS (F2."DATA", '$', 'XXXXXX72B14F839F') ) v
where F1.id=V.ID;

-- merge test applicato alla query INPS: meno semplice
 -- legge dalla sola subq per via di nomerge -- dovrebbe causare NL (o HJ se USE_NL viene commentato) -- HJ è più scalabile
SELECT /*+ NO_MERGE(v) USE_NL(V) MONITOR GATHER_PLAN_STATISTICS */ * 
FROM "Fra" F1, (SELECT F2.id FROM "Fra" F2 WHERE JSON_TEXTCONTAINS (F2."DATA", '$', 'DMRPQL73S20F839M') ) v
WHERE 
    F1.id=V.ID
AND JSON_VALUE(F1.DATA, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(F1.DATA, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
AND (
		   JSON_TEXTCONTAINS(F1.DATA, '$.request.codiceFiscale', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.cfTut_AMM_RL', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.codiceFiscaleRichiedente', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.informazioniDid.codiceFiscale', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.cfRichiedente', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.CFRichiedente', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.estremiDomanda.datiTutore.cfTutore', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.codiceFiscaleBeneficiario', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.CodiceFiscale', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.ComponenteFamiliare_CF', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.CodiceFiscaleRichiedente', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.codiceFiscaleInadempiente', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.anagrafica.codiceFiscale', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.request.anagrafica.codiceFiscaleAggiornato', 'DMRPQL73S20F839M')
		OR JSON_TEXTCONTAINS(F1.DATA, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'DMRPQL73S20F839M')
	);


-- nomerge nojoin masking
SELECT /*+ NO_MERGE(v) MONITOR GATHER_PLAN_STATISTICS */ * 
FROM (
        SELECT DATA FROM "Fra" F WHERE JSON_TEXTCONTAINS (F."DATA", '$', 'XXXXXX72B14F839F') 
     ) v
WHERE 
      JSON_VALUE(v.DATA, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(v.DATA, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
AND (
		   JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.cfTut_AMM_RL', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.informazioniDid.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.cfRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.CFRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleBeneficiario', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.CodiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.ComponenteFamiliare_CF', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.CodiceFiscaleRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleInadempiente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.anagrafica.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.anagrafica.codiceFiscaleAggiornato', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'XXXXXX72B14F839F')
	);

-- prova solo V2
        SELECT /*+ NO_MERGE(v2) */ *
        FROM (
                SELECT DATA         
                FROM "Fra" F 
                WHERE JSON_TEXTCONTAINS (F."DATA", '$', 'XXXXXX72B14F839F') 
                AND   JSON_TEXTCONTAINS (F."DATA", '$', 'timestampRequestUtc') 
            ) v2
        WHERE JSON_VALUE(v2.DATA, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(v2.DATA, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
;

-- 2 nomerge 2 inline 
SELECT /*+ NO_MERGE(v) MONITOR GATHER_PLAN_STATISTICS */ * 
FROM (
        SELECT /*+ NO_MERGE(v2) */ *
        FROM (
                SELECT DATA         
                FROM "Fra" F 
                WHERE JSON_TEXTCONTAINS (F."DATA", '$', 'XXXXXX72B14F839F') 
                AND   JSON_TEXTCONTAINS (F."DATA", '$', 'timestampRequestUtc') 
            ) v2
        WHERE JSON_VALUE(v2.DATA, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
        AND   JSON_VALUE(v2.DATA, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'     
        AND   JSON_TEXTCONTAINS (v2."DATA", '$', 'XXXXXX72B14F839F') 
      ) v
WHERE 
    (
		   JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.cfTut_AMM_RL', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.informazioniDid.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.cfRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.CFRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleBeneficiario', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.CodiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.ComponenteFamiliare_CF', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.CodiceFiscaleRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleInadempiente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.anagrafica.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.anagrafica.codiceFiscaleAggiornato', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'XXXXXX72B14F839F')
	);
--> questa a me funziona, (veloce e piano OK) ma in INPS NO| Non riproduce il piano + norows selected

select json_serialize(DATA pretty) from "Fra" where rownum<=10;

-- in effetti questa:
SELECT json_serialize(DATA RETURNING CLOB pretty) FROM "Fra" F WHERE JSON_TEXTCONTAINS (F."DATA", '$', 'timestampRequestUtc') ;
--> non restituisce righe
--riscrive con json_value:
select /*+ no_merge (v) */ count(1) from 
    (
      SELECT json_serialize(DATA RETURNING CLOB pretty) FROM "Fra" F WHERE JSON_EXISTS (F."DATA", '$.timestampRequestUtc')
    ) v;

-- prova ad unire la clausola pleonastica:
SELECT json_serialize(DATA RETURNING CLOB pretty) FROM "Fra" F WHERE JSON_EXISTS  (F."DATA", '$.timestampRequestUtc') AND JSON_TEXTCONTAINS (F."DATA", '$', 'XXXXXX72B14F839F') ;
--> funziona e fa la merge è giusta: and ( (HASPATH(timestamp) AND cf=quell0) AND cf=quello)
--  
SELECT /*+ NO_MERGE(v) MONITOR GATHER_PLAN_STATISTICS */ * 
FROM (
        SELECT /*+ NO_MERGE(v2) */ *
        FROM (
                SELECT DATA         
                FROM "Fra" F 
                WHERE JSON_EXISTS(F."DATA", '$.timestampRequestUtc') 
                AND   JSON_TEXTCONTAINS (F."DATA", '$', 'XXXXXX72B14F839F')  
            ) v2
        WHERE JSON_VALUE(v2.DATA, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
        AND   JSON_VALUE(v2.DATA, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'     
        AND   JSON_TEXTCONTAINS (v2."DATA", '$', 'XXXXXX72B14F839F') 
      ) v
WHERE 
    (
		   JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.cfTut_AMM_RL', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.informazioniDid.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.cfRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.CFRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.estremiDomanda.datiTutore.cfTutore', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleBeneficiario', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.CodiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.ComponenteFamiliare_CF', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.CodiceFiscaleRichiedente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.codiceFiscaleInadempiente', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.anagrafica.codiceFiscale', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.request.anagrafica.codiceFiscaleAggiornato', 'XXXXXX72B14F839F')
		OR JSON_TEXTCONTAINS(v.DATA, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'XXXXXX72B14F839F')
	);
    


-- con docinps
--> creazione docinps: v. generatore di codici fiscali.
-- serve indice on in-memory.
DROP INDEX docinps_IDX1;
CREATE /*+ PARALLEL nologging */ INDEX docinps_IDX1 ON docinps (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text_value dataguide off') PARALLEL 2;
alter index docinps_IDX1 noparallel;
select count(1) from docinps;
select codice_fiscale from codice_fiscale where id=1000000;
--JADHMY70M36C408N

SELECT /*+ NO_MERGE(v) MONITOR GATHER_PLAN_STATISTICS */ * 
FROM (
        SELECT /*+ NO_MERGE(v2) */ *
        FROM (
                SELECT /*+ NO_MERGE(v3)  */ *
                FROM 
                (
                    SELECT JSON_DOCUMENT        
                    FROM "DOCINPS" F 
                    WHERE   JSON_EXISTS(JSON_DOCUMENT, '$.timestampRequestUtc')
                    AND JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O')
                ) v3
                WHERE JSON_VALUE(v3.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
                AND   JSON_TEXTCONTAINS (v3."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O') 
            ) v2
        WHERE JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
        AND   JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'     
        AND   JSON_TEXTCONTAINS (v2."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O') 
      ) v
WHERE 
    (
           JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscale', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfTut_AMM_RL', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.informazioniDid.codiceFiscale', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CFRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiTutore.cfTutore', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleBeneficiario', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscale', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.ComponenteFamiliare_CF', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscaleRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleInadempiente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscale', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscaleAggiornato', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'BXNXPU27H42C698O')
    ); 



drop table my_table purge;
CREATE TABLE my_table 
(   id NUMBER, 
    json_doc BLOB CHECK (json_doc IS JSON FORMAT OSON)
)
lob (json_doc) store as (compress low)
;

-- questa è veloce: no filtro su timestamp: probabilmente va con i nuovi indici VALUE(TIMESTAMP) di 23ai
SELECT /*+ NO_MERGE(v3) MONITOR GATHER_PLAN_STATISTICS */ * 
FROM (
        SELECT /*+ NO_MERGE(v2) */ *
        FROM (
                SELECT /*+ NO_MERGE(v)  */ *
                FROM 
                (
                    SELECT JSON_DOCUMENT        
                    FROM "DOCINPS" F 
                    WHERE   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O')
                ) v
                WHERE 
				    (
						   JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscale', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfTut_AMM_RL', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleRichiedente', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.informazioniDid.codiceFiscale', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfRichiedente', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CFRichiedente', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiTutore.cfTutore', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleBeneficiario', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscale', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.ComponenteFamiliare_CF', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscaleRichiedente', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleInadempiente', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscale', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscaleAggiornato', 'BXNXPU27H42C698O')
						OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'BXNXPU27H42C698O')
					)
            ) v2
		--WHERE 1=1
        --AND   JSON_TEXTCONTAINS (v2."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O') 
      ) v3
--WHERE 1=1
--AND   JSON_VALUE(v3.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
--AND   JSON_VALUE(v3.JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'     
--AND   JSON_TEXTCONTAINS (v3."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O') 
;
alter system flush buffer_cache;
-- può essere riscritta cosi'
SELECT /*+ NO_MERGE(v)  */ *
FROM 
(
    SELECT JSON_DOCUMENT        
    FROM "DOCINPS" F 
    WHERE   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O')
) v
WHERE 
    (
           JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscale', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfTut_AMM_RL', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.informazioniDid.codiceFiscale', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CFRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiTutore.cfTutore', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleBeneficiario', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscale', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.ComponenteFamiliare_CF', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscaleRichiedente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleInadempiente', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscale', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscaleAggiornato', 'BXNXPU27H42C698O')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'BXNXPU27H42C698O')
    );

-- con il W/A di Fra:
drop table docinps_gtt purge;
-- la private non funziona.  La global funziona, e specificando ON COMMIT PRESERVE ROWS al posto del def ON COMMIT DELETE ROWS i doc temporanei scompaiono al commit.
create global temporary table docinps_gtt
   ("ID" VARCHAR2(255 BYTE), 
	"CREATED_ON" TIMESTAMP (6), 
	"LAST_MODIFIED" TIMESTAMP (6), 
	"VERSION" VARCHAR2(255 BYTE), 
    "TIMESTAMPREQUESTUTC" TIMESTAMP (6), 
    "JSON_DOCUMENT" JSON
   );

-- mappa una collection temporanea 
DECLARE
    collection SODA_COLLECTION_T;
    collectionName varchar2(25) := 'DOCINPS_GTT';
BEGIN
    collection := DBMS_SODA.create_collection(collectionName, create_mode=>DBMS_SODA.CREATE_MODE_MAP);
    DBMS_OUTPUT.put_line('Collection ' || collectionName || ' created successfully with specification: ' ||
                         json_query(collection.get_metadata, '$' PRETTY));
END;
/

set serveroutput ON;
DECLARE
    vr_arr_list KU$_VCNT := KU$_VCNT();
    collection SODA_COLLECTION_T;
    temp_coll SODA_COLLECTION_T;
    document SODA_DOCUMENT_T;
    cname varchar2(22):='docinps';
    cur SODA_CURSOR_T;
    status BOOLEAN;
    stat number;
    counter int := 0;
    conta number:=0;
    cf char(16) := 'SIOEDL01E52H445P';
    qbe varchar(4000) := '{"$textContains": "' || cf || '"}';
    qbe2 varchar(4000) := '
{
  "$and": 
  [
    {
    "$and": [ { "timestampRequestUtc": { "$timestamp": { "$gte": "1970-01-01T00:00:00.0000000" } } }, { "timestampRequestUtc": { "$timestamp": { "$lte": "9999-12-31T00:00:00.0000000" } } } ]
    },
    {
    "$or": 
  	  [
        { "request.codiceFiscale": "' || cf || '" },
        { "request.cfTut_AMM_RL": "' || cf || '" },
        { "request.codiceFiscaleRichiedente": "' || cf || '" },
        { "request.informazioniDid.codiceFiscale": "' || cf || '" },
        { "request.cfRichiedente": "' || cf || '" },
        { "request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cf": "' || cf || '" },
        { "request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cfCollegato[*]": "' || cf || '" },
        { "request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore": "' || cf || '" },
        { "request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente": "' || cf || '" },
        { "request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cf": "' || cf || '" },
        { "request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo[*].cfCollegato[*]": "' || cf || '" },
        { "request.estremiDomanda.datiTutore.cfTutore": "' || cf || '" },
        { "request.estremiDomanda.datiRichiedente.cfRichiedente": "' || cf || '" },
        { "request.codiceFiscaleBeneficiario": "' || cf || '" },
        { "response.payload.lavoratore.datiAnagrafici.codiceFiscale": "' || cf || '" }
      ]
    }
  ]
}
    ';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inizio : '||SYSTIMESTAMP);
    collection := DBMS_SODA.open_collection(cname);
    IF collection IS NULL THEN
        DBMS_OUTPUT.put_line('Collection does not exist');
    --ELSE
    --    DBMS_OUTPUT.put_line('Metadata: '|| json_query(collection.get_metadata, '$' PRETTY));
    END IF;
    cur := collection.find().filter(qbe).get_cursor();
    DBMS_OUTPUT.PUT_LINE('Fase 1 Inizio : '||SYSTIMESTAMP);

    -- temp_coll := dbms_soda.create_collection('DOCINPS_GTT'); -- non serve, usiamo la GTT
    temp_coll := dbms_soda.open_collection('DOCINPS_GTT');
    IF temp_coll IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('GTT Collection does not exist');
    --ELSE
    --    DBMS_OUTPUT.put_line('Metadata: '|| json_query(temp_coll.get_metadata, '$' PRETTY));
    END IF;
    cur := collection.find().filter(qbe).get_cursor();
    DBMS_OUTPUT.PUT_LINE('Fase 1 Inizio : '||SYSTIMESTAMP);
    WHILE cur.has_next LOOP
        document := cur.next;
        IF document IS NOT NULL THEN
            counter := counter + 1;
            DBMS_OUTPUT.PUT_LINE('Key and Counter: '||document.get_key||', '||to_char(counter));
            stat := temp_coll.insert_one(document);
            -- commit; -- no, committiamo dopo la ricerca altrimenti si scarica la GTT
        END IF;
    END LOOP;
    select count(1) into conta from "DOCINPS_GTT";
    DBMS_OUTPUT.PUT_LINE('Fase 1 GTT: '||to_char(conta));
    DBMS_OUTPUT.PUT_LINE('Fase 1 Fine : '||SYSTIMESTAMP);
    status := cur.close;
    DBMS_OUTPUT.PUT_LINE('Count : '||counter);
    DBMS_OUTPUT.PUT_LINE('Fase 2 Inizio : '||SYSTIMESTAMP);
    cur := temp_coll.find().filter(qbe2).get_cursor();
    counter := 0;
    WHILE cur.has_next LOOP
        document := cur.next;
        IF document IS NOT NULL THEN
            counter := counter + 1;
            vr_arr_list.extend();
            vr_arr_list(counter) := document.get_key;
            DBMS_OUTPUT.PUT_LINE('Internal loop Key. Counter and timestamp: '||document.get_key||', '||to_char(counter)||', '||json_query(document.get_json, '$.timestampRequestUtc' returning varchar2 PRETTY));
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Fase 2 Fine : '||SYSTIMESTAMP);
    status := cur.close;
    --stat := DBMS_SODA.drop_collection('temp_coll');  -- inutile
    DBMS_OUTPUT.PUT_LINE('Count : '||counter);
    DBMS_OUTPUT.PUT_LINE('Fine : '||SYSTIMESTAMP);
    commit; -- scarica la GTT 
    select count(1) into conta from "DOCINPS_GTT";
    DBMS_OUTPUT.PUT_LINE('GTT dopo commit: '||to_char(conta));
END;
/

-- originale Francesco
set serveroutput ON;
DECLARE
    vr_arr_list KU$_VCNT := KU$_VCNT();
    collection SODA_COLLECTION_T;
    --temp_coll SODA_COLLECTION_T;
    document SODA_DOCUMENT_T;
    cur SODA_CURSOR_T;
    status BOOLEAN;
    stat number;
    counter int := 0;
    cf char(16) := 'SIOEDL01E52H445P';
    cname varchar2(48):='docinps';
    qbe varchar(4000) := '{"$textContains": "' || cf || '"}';
    --qbe2 varchar(4000) := '{"$and":[{"timestampRequestUtc":{"$timestamp":{"$gte":"1970-01-01T00:00:00.0000000"}}},{"timestampRequestUtc":{"$timestamp":{"$lte":"9999-12-31T00:00:00.0000000"}}}]}';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inizio : '||SYSTIMESTAMP);
    collection := DBMS_SODA.open_collection(cname);
    cur := collection.find().filter(qbe).get_cursor();
    DBMS_OUTPUT.PUT_LINE('Fase 1 Inizio : '||SYSTIMESTAMP);
    --temp_coll := dbms_soda.create_collection('temp_coll');
    WHILE cur.has_next LOOP
        document := cur.next;
        IF document IS NOT NULL THEN
            counter := counter + 1;
            DBMS_OUTPUT.PUT_LINE('Internal loop Key. Counter and timestamp: '||document.get_key||', '||to_char(counter)||', '||json_query(document.get_json, '$.timestampRequestUtc' returning varchar2 PRETTY));
            --stat := temp_coll.insert_one(document);
            commit;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Fase 1 Fine : '||SYSTIMESTAMP);
    status := cur.close;
/*
    DBMS_OUTPUT.PUT_LINE('Count : '||counter);
    DBMS_OUTPUT.PUT_LINE('Fase 2 Inizio : '||SYSTIMESTAMP);
    cur := temp_coll.find().filter(qbe2).get_cursor();
    counter := 0;
    WHILE cur.has_next LOOP
        document := cur.next;
        IF document IS NOT NULL THEN
            counter := counter + 1;
            vr_arr_list.extend();
            vr_arr_list(counter) := document.get_key;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Fase 2 Fine : '||SYSTIMESTAMP);
    status := cur.close;
    stat := DBMS_SODA.drop_collection('temp_coll');
    DBMS_OUTPUT.PUT_LINE('Count : '||counter);
*/
    DBMS_OUTPUT.PUT_LINE('Fine : '||SYSTIMESTAMP);
END;
/


-- FRA_HCC_PART

-- compressa e partizionata
drop table FRA_HCC_PART purge;
CREATE TABLE "APPL1"."FRA_HCC_PART" 
   ("ID" VARCHAR2(255 BYTE) primary key not null, 
	"CREATED_ON" TIMESTAMP (6) not null, 
	"LAST_MODIFIED" TIMESTAMP (6) not null, 
	"VERSION" VARCHAR2(255 BYTE) not null, 
	"JSON_DOCUMENT" JSON , 
	"TIMESTAMPREQUESTUTC" TIMESTAMP (6) GENERATED ALWAYS AS (JSON_VALUE("JSON_DOCUMENT" FORMAT OSON , '$.timestampRequestUtc' RETURNING TIMESTAMP NULL ON ERROR)) VIRTUAL 
   ) SEGMENT CREATION IMMEDIATE 
 COLUMN STORE COMPRESS FOR QUERY HIGH NO ROW LEVEL LOCKING 
 LOGGING
 TABLESPACE "USERS"
 INMEMORY TEXT (JSON_DOCUMENT)
 JSON ("JSON_DOCUMENT") STORE AS (TABLESPACE "USERS"  CHUNK 8192) 
 PARTITION BY RANGE (TIMESTAMPREQUESTUTC) 
  --INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH') ) 
  INTERVAL ( NUMTODSINTERVAL (7, 'DAY') )
  ( 
    PARTITION OLD_DATA VALUES LESS THAN (TIMESTAMP '2023-08-01 00:00:00.000000')
  )
;

DECLARE
    collection SODA_COLLECTION_T;
    collectionName varchar2(25) := 'FRA_HCC_PART';
BEGIN
    collection := DBMS_SODA.create_collection(collectionName, create_mode=>DBMS_SODA.CREATE_MODE_MAP);
    DBMS_OUTPUT.put_line('Collection ' || collectionName || ' created successfully with specification: ' ||
                         json_query(collection.get_metadata, '$' PRETTY));
END;
/

alter session enable parallel dml;
select * from user_constraints where table_name='FRA_HCC_PART';
select * from user_cons_columns where table_name='FRA_HCC_PART';

declare
 i number:=0;
 bs number :=1000000;
begin
  for i in 1..20 -- milioni se bs=1E6
  loop
    insert /*+ append parallel*/  into "APPL1"."FRA_HCC_PART" (id, created_on, last_modified, version, JSON_DOCUMENT)
    select /*+ parallel (D, 4) */ id, created_on, last_modified, version, JSON_DOCUMENT from "APPL1"."DOCINPS" D
    where id between ltrim(to_char((i-1)*bs+1)) and ltrim(to_char(i*bs));
    commit;
    dbms_output.put_line('Batch '||to_char(i)||' completato');
  end loop;
end;
/
    
select /*+ paralle (d, 16) */ count(1) from fra_hcc_part d;

select count(1) from user_tab_partitions where table_name='FRA_HCC_PART';
select * from user_tab_partitions where table_name='FRA_HCC_PART';
select count(1) from "APPL1"."FRA_HCC" union all
select count(1) from "APPL1"."FRA_HCC_PART";

DROP INDEX FRA_HCC_PART_IDX1;
CREATE INDEX FRA_HCC_PART_IDX1 ON FRA_HCC_PART (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync  (every "freq=secondly; interval=1") search_on text_value dataguide off') parallel 14
    LOCAL;
select count(1) from user_ind_partitions where index_name='FRA_HCC_PART_IDX1';
   
DROP INDEX FRA_HCC_PART_IDX2;
DROP INDEX FRA_HCC_PART_IDX3;
CREATE INDEX FRA_HCC_PART_IDX2 ON FRA_HCC_PART (json_value(data, '$.timestampRequestUtc' ERROR ON ERROR) asc) LOCAL;
CREATE INDEX FRA_HCC_PART_IDX3 ON FRA_HCC_PART (timestampRequestUtc) LOCAL;
select count(1) from user_ind_partitions where index_name='FRA_HCC_PART_IDX2';

alter table FRA_HCC_PART parallel 8;
exec dbms_stats.gather_table_stats('','FRA_HCC_PART', degree=>8);
select dbid from v$database;

-- prova sul cf mascherato con clausola pleonastica sulla tavola partizionata e compress HCC e con l'indice
-->manca indice
SELECT * FROM FRA_HCC_PART
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'SIOEDL01E52H445P' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'SIOEDL01E52H445P')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'SIOEDL01E52H445P')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'SIOEDL01E52H445P')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'SIOEDL01E52H445P')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'SIOEDL01E52H445P')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'SIOEDL01E52H445P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'SIOEDL01E52H445P' ) 
          )
    )
;

select name, value from v$parameter where isdefault='FALSE';
select distinct isdefault from v$parameter;
set lines 150 pages 999
col name for a55 
col value for a66

select sum(bytes)/1024/1024 MB from  user_segments where segment_name='DOCINPS';
select sum(bytes)/1024/1024 MB from  user_segments where segment_name='FRA_HCC_PART';


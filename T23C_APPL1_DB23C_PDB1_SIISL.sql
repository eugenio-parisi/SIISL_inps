-- basato su /home/oracle/T21C_APPL1_PDB1_SIISL.sql
show user;
select * from v$version;
/*
select * from dba_data_Files;
select * from dba_temp_Files;
select * from dba_tablespaces;

alter tablespace temp add tempfile size 1g autoextend on next 1g maxsize unlimited;
*/

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

select codice_fiscale from codice_fiscale where id>1000001 and rownum<=10;

-- non-compressa
set serverout on
declare
r number:=0;
begin
r:=DBMS_SODA.drop_collection(collection_name=>'FRA', purge=>true, drop_mapped_table=>true);
IF r>0 THEN
    DBMS_OUTPUT.put_line('Collection dropped');
ELSE
    DBMS_OUTPUT.put_line('Collection does not exist');
END IF;
end;
/

drop table FRA  purge;
CREATE TABLE "APPL1"."FRA"
   ("ID" VARCHAR2(255 BYTE), 
	"TIMESTAMPREQUESTUTC" TIMESTAMP (6), 
	"LAST_MODIFIED" TIMESTAMP (6), 
	"VERSION" VARCHAR2(255 BYTE), 
	"JSON_DOCUMENT" JSON
   ) SEGMENT CREATION IMMEDIATE 
/*ROW STORE COMPRESS ADVANCED*/
LOGGING
/*INMEMORY TEXT (JSON_DOCUMENT)*/
/* JSON(JSON_DOCUMENT) store as (compression high)*/
;

DECLARE
    collection SODA_COLLECTION_T;
    metadata VARCHAR2(4000) :=  '{"creationTimeColumn": {"name" : "TIMESTAMPREQUESTUTC" }, "lastModifiedColumn" : { "name" : "LAST_MODIFIED"}, "versionColumn" : {"name" : "VERSION", "method" : "UUID" } }';
BEGIN
    collection := DBMS_SODA.create_collection('FRA', metadata, DBMS_SODA.CREATE_MODE_MAP);
    DBMS_OUTPUT.put_line ('Collection specification: ' ||json_query(collection.get_metadata, '$' PRETTY));
END;
/

-- la collection non è partizionata né compressa (in alcuna sua parte)
desc FRA

-- carica i dati e crea l'indice
alter index FRA_IDX1 noparallel;
DROP INDEX FRA_IDX1 force;
DROP INDEX FRA_IDX1;

declare
 i number:=0;
 bs number :=100000;
begin
  for i in 1..200 -- milioni se bs=1E5
  loop
    insert /*+ append parallel*/  into FRA (id, TIMESTAMPREQUESTUTC, last_modified, version, JSON_DOCUMENT)
    select /*+ parallel (D, 4) */ id, created_on, last_modified, version, JSON_DOCUMENT from "APPL1"."DOCINPS"
    where id between ltrim(to_char((i-1)*bs+1)) and ltrim(to_char(i*bs));
    commit;
    dbms_output.put_line('Batch '||to_char(i)||' completato');
  end loop;
end;
/
truncate table fra;
select /*+ parallel (d, 8) */ count(1) from fra d;
-- serve taaaaanto temp tablespace...
CREATE INDEX FRA_IDX1 ON FRA (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text  dataguide off') PARALLEL 8;
alter index FRA_IDX1 noparallel;
select count(1) from FRA;

--query su FRA
-- originale
alter system flush buffer_cache;
SELECT * FROM FRA
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      --AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-- lenta!

-- con pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-- lenta!!! inizialmente era veloce!!!

-- senza timestamp con pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA
WHERE
    (/*     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND */( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-->Veloce!

-- senza timestamp senza pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA
WHERE
    (/*     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND  */( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-->Veloce!

--compressa ACO
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

drop table FRA_ACO  purge;
CREATE TABLE "APPL1"."FRA_ACO"
   ("ID" VARCHAR2(255 BYTE), 
	"TIMESTAMPREQUESTUTC" TIMESTAMP (6), 
	"LAST_MODIFIED" TIMESTAMP (6), 
	"VERSION" VARCHAR2(255 BYTE), 
	"JSON_DOCUMENT" JSON
   ) SEGMENT CREATION IMMEDIATE 
ROW STORE COMPRESS ADVANCED -- comprime i metadati
LOGGING
/* INMEMORY TEXT (JSON_DOCUMENT) -- futura abilitazione di INMEMORY */
JSON(JSON_DOCUMENT) store as (compress high) -- comprime ACO i documenti
;

DECLARE
    collection SODA_COLLECTION_T;
    metadata VARCHAR2(4000) :=  '{"creationTimeColumn": {"name" : "TIMESTAMPREQUESTUTC" }, "lastModifiedColumn" : { "name" : "LAST_MODIFIED"}, "versionColumn" : {"name" : "VERSION", "method" : "UUID" } }';
BEGIN
    collection := DBMS_SODA.create_collection('FRA_ACO', metadata, DBMS_SODA.CREATE_MODE_MAP);
    DBMS_OUTPUT.put_line ('Collection specification: ' ||json_query(collection.get_metadata, '$' PRETTY));
END;
/

-- la collection non è partizionata né compressa (in alcuna sua parte)
desc FRA_ACO

-- carica i dati e crea l'indice
alter index FRA_ACO_IDX1 noparallel;
DROP INDEX FRA_ACO_IDX1 force;
DROP INDEX FRA_ACO_IDX1;

declare
 i number:=0;
 bs number :=100000;
begin
  for i in 1..200 -- milioni se bs=1E5
  loop
    insert /*+ append parallel*/  into FRA_ACO (id, TIMESTAMPREQUESTUTC, last_modified, version, JSON_DOCUMENT)
    select /*+ parallel (D, 4) */ id, created_on, last_modified, version, JSON_DOCUMENT from "APPL1"."DOCINPS"
    where id between ltrim(to_char((i-1)*bs+1)) and ltrim(to_char(i*bs));
    commit;
    dbms_output.put_line('Batch '||to_char(i)||' completato');
  end loop;
end;
/

select /*+ parallel (d, 8) */ count(1) from FRA_ACO d;
-- serve taaaaanto temp tablespace...
CREATE INDEX FRA_ACO_IDX1 ON FRA_ACO (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text  dataguide off') PARALLEL 8;
alter index FRA_ACO_IDX1 noparallel;
select count(1) from FRA_ACO;

--query su FRA_ACO
-- originale
alter system flush buffer_cache;
SELECT * FROM FRA_ACO
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      --AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-- lenta!

-- con pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA_ACO
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-- lenta!!! inizialmente era veloce!!!

-- senza timestamp con pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA_ACO
WHERE
    (/*     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND */( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-->Veloce!

-- senza timestamp senza pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA_ACO
WHERE
    (/*     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND  */( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-->Veloce!


--compressa HCC e non partizionata 
set serverout on
declare
r number:=0;
begin
r:=DBMS_SODA.drop_collection(collection_name=>'FRA_HCC', purge=>true, drop_mapped_table=>true);
IF r>0 THEN
    DBMS_OUTPUT.put_line('Collection dropped');
ELSE
    DBMS_OUTPUT.put_line('Collection does not exist');
END IF;
end;
/

drop table FRA_HCC  purge;
CREATE TABLE "APPL1"."FRA_HCC" 
   ("ID" VARCHAR2(255 BYTE), 
	"TIMESTAMPREQUESTUTC" TIMESTAMP (6), 
	"LAST_MODIFIED" TIMESTAMP (6), 
	"VERSION" VARCHAR2(255 BYTE), 
	"JSON_DOCUMENT" JSON
   ) SEGMENT CREATION IMMEDIATE 
 COLUMN STORE COMPRESS FOR QUERY HIGH ROW LEVEL LOCKING 
	/* If you specify ROW LEVEL LOCKING, then Oracle 
	   Database uses row-level locking during DML
	   operations. This improves the performance */
 LOGGING
 TABLESPACE "USERS"
/* INMEMORY TEXT (JSON_DOCUMENT) -- futura abilitazione di INMEMORY */
/* PARTITION BY RANGE (TIMESTAMPREQUESTUTC) 
  --INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH') ) 
  INTERVAL ( NUMTODSINTERVAL (7, 'DAY') )
  ( 
    PARTITION OLD_DATA VALUES LESS THAN (TIMESTAMP '2023-08-01 00:00:00.000000')
  )
*/
;

DECLARE
    collection SODA_COLLECTION_T;
    metadata VARCHAR2(4000) :=  '{"creationTimeColumn": {"name" : "TIMESTAMPREQUESTUTC" }, "lastModifiedColumn" : { "name" : "LAST_MODIFIED"}, "versionColumn" : {"name" : "VERSION", "method" : "UUID" } }';
BEGIN
    collection := DBMS_SODA.create_collection('FRA_HCC', metadata, DBMS_SODA.CREATE_MODE_MAP);
    DBMS_OUTPUT.put_line ('Collection specification: ' ||json_query(collection.get_metadata, '$' PRETTY));
END;
/

-- la collection è compressa HCC con il livello di compressione migliore per l'OLTP
desc FRA_HCC

-- carica i dati e crea l'indice
alter index FRA_HCC_IDX1 noparallel;
DROP INDEX FRA_HCC_IDX1 force;
DROP INDEX FRA_HCC_IDX1;

declare
 i number:=0;
 bs number :=1000000;
begin
  for i in 1..20 -- milioni se bs=1E6
  loop
    insert /*+ append parallel*/  into FRA_HCC (id, TIMESTAMPREQUESTUTC, last_modified, version, JSON_DOCUMENT)
    select /*+ parallel (D, 4) */ id, created_on, last_modified, version, JSON_DOCUMENT from "APPL1"."DOCINPS"
    where id between ltrim(to_char((i-1)*bs+1)) and ltrim(to_char(i*bs));
    commit;
    dbms_output.put_line('Batch '||to_char(i)||' completato');
  end loop;
end;
/

select /*+ parallel (d, 8) */ count(1) from FRA_HCC d;
exec dbms_stats.gather_table_stats('','FRA_HCC',degree=>8);

-- serve taaaaanto temp tablespace...
CREATE INDEX FRA_HCC_IDX1 ON FRA_HCC (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text  dataguide off') 
	PARALLEL 4;
alter index FRA_HCC_IDX1 noparallel;

--query su FRA_HCC
-- originale
alter system flush buffer_cache;
SELECT * FROM FRA_HCC
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      --AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-- lenta!

-- con pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA_HCC
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-- lenta!!! inizialmente era veloce!!!

-- senza timestamp con pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA_HCC
WHERE
    (/*     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND */( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-->Veloce!

-- senza timestamp senza pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA_HCC
WHERE
    (/*     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND  */( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-->Veloce!

--compressa HCC e partizionata 
set serverout on
declare
r number:=0;
begin
r:=DBMS_SODA.drop_collection(collection_name=>'FRA_HCC_PART', purge=>true, drop_mapped_table=>true);
IF r>0 THEN
    DBMS_OUTPUT.put_line('Collection dropped');
ELSE
    DBMS_OUTPUT.put_line('Collection does not exist');
END IF;
end;
/

drop table FRA_HCC_PART  purge;
CREATE TABLE "APPL1"."FRA_HCC_PART" 
   ("ID" VARCHAR2(255 BYTE), 
	"TIMESTAMPREQUESTUTC" TIMESTAMP (6), 
	"LAST_MODIFIED" TIMESTAMP (6), 
	"VERSION" VARCHAR2(255 BYTE), 
	"JSON_DOCUMENT" JSON
   ) SEGMENT CREATION IMMEDIATE 
 COLUMN STORE COMPRESS FOR QUERY HIGH ROW LEVEL LOCKING 
	/* If you specify ROW LEVEL LOCKING, then Oracle 
	   Database uses row-level locking during DML
	   operations. This improves the performance */
 LOGGING
 TABLESPACE "USERS"
/* INMEMORY TEXT (JSON_DOCUMENT) -- futura abilitazione di INMEMORY */
 PARTITION BY RANGE (TIMESTAMPREQUESTUTC) 
  --INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH') ) 
  INTERVAL ( NUMTODSINTERVAL (7, 'DAY') )
  ( 
    PARTITION OLD_DATA VALUES LESS THAN (TIMESTAMP '2023-08-01 00:00:00.000000')
  )
;

DECLARE
    collection SODA_COLLECTION_T;
    metadata VARCHAR2(4000) :=  '{"creationTimeColumn": {"name" : "TIMESTAMPREQUESTUTC" }, "lastModifiedColumn" : { "name" : "LAST_MODIFIED"}, "versionColumn" : {"name" : "VERSION", "method" : "UUID" } }';
BEGIN
    collection := DBMS_SODA.create_collection('FRA_HCC_PART', metadata, DBMS_SODA.CREATE_MODE_MAP);
    DBMS_OUTPUT.put_line ('Collection specification: ' ||json_query(collection.get_metadata, '$' PRETTY));
END;
/

-- la collection è partizionata e compressa HCC con il livello di compressione migliore per l'OLTP
desc FRA_HCC_PART

-- carica i dati e crea l'indice
alter index FRA_HCC_PART_IDX1 noparallel;
DROP INDEX FRA_HCC_PART_IDX1 force;
DROP INDEX FRA_HCC_PART_IDX1;

declare
 i number:=0;
 bs number :=1000000;
begin
  for i in 1..20 -- milioni se bs=1E6
  loop
    insert /*+ append parallel*/  into FRA_HCC_PART (id, TIMESTAMPREQUESTUTC, last_modified, version, JSON_DOCUMENT)
    select /*+ parallel (D, 4) */ id, created_on, last_modified, version, JSON_DOCUMENT from "APPL1"."DOCINPS"
    where id between ltrim(to_char((i-1)*bs+1)) and ltrim(to_char(i*bs));
    commit;
    dbms_output.put_line('Batch '||to_char(i)||' completato');
  end loop;
end;
/

exec dbms_stats.gather_table_stats('','FRA_HCC_PART',degree=>8);
select /*+ parallel (d, 8) */ count(1) from FRA_HCC_PART d;

-- serve taaaaanto temp tablespace...
CREATE INDEX FRA_HCC_PART_IDX1 ON FRA_HCC_PART (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text  dataguide off') 
	PARALLEL 4
	LOCAL;
alter index FRA_HCC_PART_IDX1 noparallel;
select count(1) from FRA_HCC_PART;

--query su FRA_HCC_PART
-- originale
alter system flush buffer_cache;
SELECT * FROM FRA_HCC_PART
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      --AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-- lenta!

-- con pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA_HCC_PART
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-- lenta!!! inizialmente era veloce!!!

-- senza timestamp con pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA_HCC_PART
WHERE
    (/*     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND */( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-->Veloce!

-- senza timestamp senza pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA_HCC_PART
WHERE
    (/*     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND  */( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' ) 
          )
    )
;
-->Veloce!

-- controlla la compressione
with 
    us as (select segment_name as collection_name, sum(bytes) as sum_bytes
        from user_segments
        where segment_name in ('FRA_ACO','DOCINPS','FRA','FRA_HCC', 'FRA_HCC_PART') 
        group by segment_name)
   ,nr as (select nvl(num_rows,100000000) docs, table_name, INMEMORY, nvl(compress_for,'disabilitata') as compression, PARTITIONED from user_tables)
   ,pc as (select table_name as part_table_name, count(1) parts, listagg (distinct compress_for) as part_compression from user_tab_partitions group by table_name)
   ,uc as (select segment_name, sum(bytes) sum_uncompress_bytes 
        from user_segments
        where segment_name='FRA' group by segment_name)
select us.collection_name, nr.docs, inmemory, partitioned, nvl(to_char(pc.parts),'non partizionata') as num_part, 
    decode(partitioned,'YES','v.comp.liv.partizioni',compression) as compressione_liv_collection, part_compression as compressione_liv_part,
    round(1/(sum_bytes/sum_uncompress_bytes),2) comp_factor, round(docs/(sum_bytes/1024/1024/1024)) docs_per_gb
from us,nr,uc,pc
where table_Name=collection_name and table_Name=part_table_name(+)
;


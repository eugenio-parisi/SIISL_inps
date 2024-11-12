set lines 132 pages 999 time on timing on
-- crea l'indice
-- text e non text_value
alter index docinps_IDX1 noparallel;
DROP INDEX docinps_IDX1;
-- server taaaaanto temp tablespace...
CREATE INDEX docinps_IDX1 ON docinps (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text  dataguide off') PARALLEL 4;
alter index docinps_IDX1 noparallel;
select count(1) from docinps;
select codice_fiscale from codice_fiscale where id=1000000;
spool off

spool test_recap_text
/*
SQL> select codice_fiscale from codice_fiscale where id>1000001 and rownum<=10;

CODICE_FISCALE
----------------
AXRFVL36B46A210Q
SBIAAQ64C43D320P
HBPOFD20B28A329G
OKPNUZ64E48H228Q
DLRINZ28E53B362E

FTTBIW42L24B647S
THINTS00R45B455X
BXNXPU27H42C698O
WRWUEL62R16A985L
TCIRSU95R24C442Y


*/
prompt test_recap -- tutte le query da docinps
set autotrace trace
prompt query originale de applicativo
SELECT * FROM docinps
WHERE
    ( ( JSON_VALUE("JSON_DOCUMENT", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("JSON_DOCUMENT", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      --AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'AXRFVL36B46A210Q' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'AXRFVL36B46A210Q')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'AXRFVL36B46A210Q')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'AXRFVL36B46A210Q')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'AXRFVL36B46A210Q')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'AXRFVL36B46A210Q')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'AXRFVL36B46A210Q' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'AXRFVL36B46A210Q' ) 
          )
    );
/*
Elapsed: 00:00:44.59

Execution Plan
----------------------------------------------------------
Plan hash value: 1235534266

----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |              |     1 |  2238 |   157   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID BATCHED| DOCINPS      |     1 |  2238 |   157   (0)| 00:00:01 |
|   2 |   BITMAP CONVERSION TO ROWIDS       |              |       |       |            |          |
|   3 |    BITMAP AND                       |              |       |       |            |          |
|   4 |     BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|   5 |      SORT ORDER BY                  |              |       |       |            |          |
|*  6 |       DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|   7 |     BITMAP OR                       |              |       |       |            |          |
|   8 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|   9 |       SORT ORDER BY                 |              |       |       |            |          |
|* 10 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  11 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  12 |       SORT ORDER BY                 |              |       |       |            |          |
|* 13 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  14 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  15 |       SORT ORDER BY                 |              |       |       |            |          |
|* 16 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  17 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  18 |       SORT ORDER BY                 |              |       |       |            |          |
|* 19 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  20 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  21 |       SORT ORDER BY                 |              |       |       |            |          |
|* 22 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  23 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  24 |       SORT ORDER BY                 |              |       |       |            |          |
|* 25 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  26 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  27 |       SORT ORDER BY                 |              |       |       |            |          |
|* 28 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  29 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  30 |       SORT ORDER BY                 |              |       |       |            |          |
|* 31 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  32 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  33 |       SORT ORDER BY                 |              |       |       |            |          |
|* 34 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  35 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  36 |       SORT ORDER BY                 |              |       |       |            |          |
|* 37 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  38 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  39 |       SORT ORDER BY                 |              |       |       |            |          |
|* 40 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  41 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  42 |       SORT ORDER BY                 |              |       |       |            |          |
|* 43 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  44 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  45 |       SORT ORDER BY                 |              |       |       |            |          |
|* 46 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  47 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  48 |       SORT ORDER BY                 |              |       |       |            |          |
|* 49 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  50 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  51 |       SORT ORDER BY                 |              |       |       |            |          |
|* 52 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  53 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  54 |       SORT ORDER BY                 |              |       |       |            |          |
|* 55 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  56 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  57 |       SORT ORDER BY                 |              |       |       |            |          |
|* 58 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  59 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  60 |       SORT ORDER BY                 |              |       |       |            |          |
|* 61 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  62 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  63 |       SORT ORDER BY                 |              |       |       |            |          |
|* 64 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  65 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  66 |       SORT ORDER BY                 |              |       |       |            |          |
|* 67 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|  68 |      BITMAP CONVERSION FROM ROWIDS  |              |       |       |            |          |
|  69 |       SORT ORDER BY                 |              |       |       |            |          |
|* 70 |        DOMAIN INDEX                 | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(JSON_VALUE("JSON_DOCUMENT" /*+ LOB_BY_VALUE */  FORMAT OSON ,
              '$.timestampRequestUtc' RETURNING VARCHAR2(4000) NULL ON
              ERROR)>='1970-01-01T00:00:00.0000000' AND JSON_VALUE("JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              FORMAT OSON , '$.timestampRequestUtc' RETURNING VARCHAR2(4000) NULL ON
              ERROR)<='9999-12-31T00:00:00.0000000')
   6 - access("CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'HASPATH(/timestampRequestUtc)')>0)
  10 - access("CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(AXRFVL36B46A210Q) INPATH (/request/codiceFiscale)')>0 AND
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(AXRFVL36B46A210Q)
              INPATH (/request/cfTut_AMM_RL)')>0 AND "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(AXRFVL36B46A210Q) INPATH (/request/codiceFiscaleRichiedente)')>0 AND
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(AXRFVL36B46A210Q)
              INPATH (/request/informazioniDid/codiceFiscale)')>0 AND
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(AXRFVL36B46A210Q)
              INPATH (/request/cfRichiedente)')>0 AND "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" 
...
  67 - access("CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(AXRFVL36B46A210Q) INPATH (/request/anagrafica/codiceFiscaleAggiornato)')>0 AND
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(AXRFVL36B46A210Q)
              INPATH (/response/mlpsResponse/esitoAnagrafica/codiceFiscale)')>0)
  70 - access("CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(AXRFVL36B46A210Q) INPATH (/response/mlpsResponse/esitoAnagrafica/codiceFiscale)')>0)
			  
Highlights: 
- la query è leggermente  più veloce di quanto si registra in INPS 44 sec invece di oltre 1min; potrebbe essere il masking
- il piano probabilmente coincide con quello riproducibile da INPS
Lowlights:
- il piano e' perfettibile, il filtro 9 si applica all'intero docset.
*/

alter system flush buffer_cache;

prompt query con singola clausola pleonastica
SELECT * FROM docinps
WHERE
    ( ( JSON_VALUE("JSON_DOCUMENT", '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000'
        AND JSON_VALUE("JSON_DOCUMENT", '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000' 
      )
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'SBIAAQ64C43D320P' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'SBIAAQ64C43D320P')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'SBIAAQ64C43D320P')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'SBIAAQ64C43D320P')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'SBIAAQ64C43D320P')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'SBIAAQ64C43D320P')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'SBIAAQ64C43D320P' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'SBIAAQ64C43D320P' ) 
          )
    );
	
/*
Elapsed: 00:00:43.90

Execution Plan
----------------------------------------------------------
Plan hash value: 2564694513

----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |              |     1 |  2238 |    11   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID BATCHED| DOCINPS      |     1 |  2238 |    11   (0)| 00:00:01 |
|   2 |   BITMAP CONVERSION TO ROWIDS       |              |       |       |            |          |
|   3 |    BITMAP AND                       |              |       |       |            |          |
|   4 |     BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|   5 |      SORT ORDER BY                  |              |       |       |            |          |
|*  6 |       DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|   7 |     BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|   8 |      SORT ORDER BY                  |              |       |       |            |          |
|*  9 |       DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(JSON_VALUE("JSON_DOCUMENT" /*+ LOB_BY_VALUE */  FORMAT OSON ,
              '$.timestampRequestUtc' RETURNING VARCHAR2(4000) NULL ON
              ERROR)>='1970-01-01T00:00:00.0000000' AND JSON_VALUE("JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              FORMAT OSON , '$.timestampRequestUtc' RETURNING VARCHAR2(4000) NULL ON
              ERROR)<='9999-12-31T00:00:00.0000000' AND ("CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT"
              /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P) INPATH (/request/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/cfTut_AMM_RL)')>0 OR "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P) INPATH (/request/codiceFiscaleRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/informazioniDid/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/cfRichiedente)')>0 OR "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P) INPATH (/request/CFRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/esitoElaborazione/esitiINPS/nucleoISEEDellaDomanda/soggettiNucleo)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/esitoElaborazione/estremiDomanda/datiTutore/cfTutore)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/esitoElaborazione/estremiDomanda/datiRichiedente/cfRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/esitiINPS/nucleoISEEDellaDomanda/soggettiNucleo)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/estremiDomanda/datiTutore/cfTutore)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/estremiDomanda/datiRichiedente/cfRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/response/payload/lavoratore/datiAnagrafici/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/codiceFiscaleBeneficiario)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/CodiceFiscale)')>0 OR "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P) INPATH (/request/ComponenteFamiliare_CF)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/CodiceFiscaleRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/codiceFiscaleInadempiente)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/anagrafica/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/request/anagrafica/codiceFiscaleAggiornato)')>0 OR
              "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(SBIAAQ64C43D320P)
              INPATH (/response/mlpsResponse/esitoAnagrafica/codiceFiscale)')>0))
   6 - access("CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(SBIAAQ64C43D320P)')>0 AND "CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE
              */ ,'HASPATH(/timestampRequestUtc)')>0)
   9 - access("CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'HASPATH(/timestampRequestUtc)')>0)


Statistics
----------------------------------------------------------
       4247  recursive calls
          0  db block gets
     172931  consistent gets
         15  physical reads
     142076  redo size
       3343  bytes sent via SQL*Net to client
        624  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
          7  sorts (memory)
          0  sorts (disk)
          1  rows processed

Highlights: 
- la query è sempre leggermente più veloce rispetto ad INPS
Lowlights:
- il piano è perfettibile, il filtro 9 si applica a tutto il docset.

*/

alter system flush buffer_cache;

prompt query con doppia clausola pleonastica che ha il piano buono anche in INPS ma performance non buone in INPS, uguali alle query qui sopra, oltre il minuto:
SELECT /*+ NO_MERGE(v) MONITOR GATHER_PLAN_STATISTICS */ * 
FROM (
        SELECT /*+ NO_MERGE(v2) */ *
        FROM (
                SELECT JSON_DOCUMENT         
                FROM "DOCINPS" F 
                WHERE JSON_EXISTS (F."JSON_DOCUMENT", '$.timestampRequestUtc') 
                AND   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'HBPOFD20B28A329G') 
            ) v2
        WHERE JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
        AND   JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'     
        AND   JSON_TEXTCONTAINS (v2."JSON_DOCUMENT", '$', 'HBPOFD20B28A329G') 
      ) v
WHERE 
    (
           JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscale', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfTut_AMM_RL', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleRichiedente', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.informazioniDid.codiceFiscale', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfRichiedente', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CFRichiedente', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiTutore.cfTutore', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleBeneficiario', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscale', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.ComponenteFamiliare_CF', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscaleRichiedente', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleInadempiente', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscale', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscaleAggiornato', 'HBPOFD20B28A329G')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'HBPOFD20B28A329G')
    );

/*
Elapsed: 00:00:44.20

Execution Plan
----------------------------------------------------------
Plan hash value: 13833576

------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |              |     1 |  4102 |    11   (0)| 00:00:01 |
|   1 |  VIEW                                 |              |     1 |  4102 |    11   (0)| 00:00:01 |
|   2 |   VIEW                                |              |     1 |  4102 |    11   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS BY INDEX ROWID BATCHED| DOCINPS      |     1 |  2216 |    11   (0)| 00:00:01 |
|   4 |     BITMAP CONVERSION TO ROWIDS       |              |       |       |            |          |
|   5 |      BITMAP AND                       |              |       |       |            |          |
|   6 |       BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|   7 |        SORT ORDER BY                  |              |       |       |            |          |
|*  8 |         DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|   9 |       BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|  10 |        SORT ORDER BY                  |              |       |       |            |          |
|* 11 |         DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(JSON_VALUE("JSON_DOCUMENT" /*+ LOB_BY_VALUE */  FORMAT OSON ,
              '$.timestampRequestUtc' RETURNING VARCHAR2(4000) NULL ON
              ERROR)>='1970-01-01T00:00:00.0000000' AND JSON_VALUE("JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              FORMAT OSON , '$.timestampRequestUtc' RETURNING VARCHAR2(4000) NULL ON
              ERROR)<='9999-12-31T00:00:00.0000000' AND ("CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH (/request/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/cfTut_AMM_RL)')>0 OR "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(HBPOFD20B28A329G) INPATH (/request/codiceFiscaleRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/informazioniDid/codiceFiscale)')>0 OR "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH (/request/cfRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/CFRichiedente)')>0 OR "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(HBPOFD20B28A329G) INPATH (/request/esitoElaborazione/esitiINPS/nucleoISEEDellaDomanda/sogge
              ttiNucleo)')>0 OR "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(HBPOFD20B28A329G) INPATH (/request/esitoElaborazione/estremiDomanda/datiTutore/cfTutore)')>
              0 OR "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/esitoElaborazione/estremiDomanda/datiRichiedente/cfRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/esitiINPS/nucleoISEEDellaDomanda/soggettiNucleo)')>0 OR
              "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/estremiDomanda/datiTutore/cfTutore)')>0 OR "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT"
              /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/estremiDomanda/datiRichiedente/cfRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/response/payload/lavoratore/datiAnagrafici/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/codiceFiscaleBeneficiario)')>0 OR "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH (/request/CodiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/ComponenteFamiliare_CF)')>0 OR "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH (/request/CodiceFiscaleRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/codiceFiscaleInadempiente)')>0 OR "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH (/request/anagrafica/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/request/anagrafica/codiceFiscaleAggiornato)')>0 OR "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT"
              /*+ LOB_BY_VALUE */ ,'(HBPOFD20B28A329G) INPATH
              (/response/mlpsResponse/esitoAnagrafica/codiceFiscale)')>0))
   8 - access("CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'HASPATH(/timestampRequestUtc)')>0 AND "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(HBPOFD20B28A329G)')>0)
  11 - access("CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(HBPOFD20B28A329G)')>0)


Statistics
----------------------------------------------------------
       4100  recursive calls
          0  db block gets
     172617  consistent gets
          7  physical reads
     141380  redo size
       3005  bytes sent via SQL*Net to client
        428  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
          7  sorts (memory)
          0  sorts (disk)
          1  rows processed

Highlights: 
- la query è veloce; più veloce che non in INPS, dove impiega 1m16s
Lowlights:
- il piano è teoricamente buono, il filtro 9 si applica a tutto il docset; JSON_VALUE e JSON_TEXTCONTAINS potrebbero non essere ugualmente efficaci insieme al filtro 8


*/

alter system flush buffer_cache;

prompt query solo Text (no JSON), anche nota come s2.SQL
SELECT /*+ MONITOR GATHER_PLAN_STATISTICS */ * FROM "DOCINPS"
WHERE JSON_TEXTCONTAINS(JSON_DOCUMENT, '$', 'OKPNUZ64E48H228Q')
/

/*
Elapsed: 00:00:00.01

Execution Plan
----------------------------------------------------------
Plan hash value: 864687371

--------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              | 10000 |    21M|  6632   (1)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| DOCINPS      | 10000 |    21M|  6632   (1)| 00:00:01 |
|*  2 |   DOMAIN INDEX              | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(OKPNUZ64E48H228Q)')>0)


Statistics
----------------------------------------------------------
        140  recursive calls
          0  db block gets
         97  consistent gets
          5  physical reads
        512  redo size
       3329  bytes sent via SQL*Net to client
        624  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
          1  rows processed

Highlights: 
- immediata (notare il che codice fiscale è nuovo, mai interrogato);  veloce anche in INPS, dove impiega 1.4 secs
- notevole la differenza di tempo con INPS, 2 ordini di grandezza: secondi vs centesimi

*/
alter system flush buffer_cache;

prompt query JSON solo TEXTCONTAINS, anche nota come s3
SELECT /*+ MONITOR GATHER_PLAN_STATISTICS */ * FROM "DOCINPS"
WHERE CONTAINS ("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */,'(DLRINZ28E53B362E)')>0;

/*
Elapsed: 00:00:00.01

Execution Plan
----------------------------------------------------------
Plan hash value: 864687371

--------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              | 10000 |    21M|  6632   (1)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| DOCINPS      | 10000 |    21M|  6632   (1)| 00:00:01 |
|*  2 |   DOMAIN INDEX              | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("CTXSYS"."CONTAINS"("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(DLRINZ28E53B362E)')>0)


Statistics
----------------------------------------------------------
        171  recursive calls
          0  db block gets
        116  consistent gets
          7  physical reads
        576  redo size
       3353  bytes sent via SQL*Net to client
        624  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
          2  sorts (memory)
          0  sorts (disk)
          1  rows processed

Highlights: 
- immediata (notare il che codice fiscale è sempre nuovo, mai interrogato);  veloce anche in INPS, dove impiega 1.3 secs
- notevole la differenza di tempo con INPS, 2 ordini di grandezza: secondi vs centesimi

*/
alter system flush buffer_cache;

prompt vista più interna con JSON_VALUE, da test3 query 1
SELECT JSON_DOCUMENT         
FROM "DOCINPS" F 
WHERE JSON_EXISTS (F."JSON_DOCUMENT", '$.timestampRequestUtc') 
AND   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'THINTS00R45B455X') 
/

/*
Elapsed: 00:00:43.78

Execution Plan
----------------------------------------------------------
Plan hash value: 2564694513

----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |              |     5 | 11080 |    11   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| DOCINPS      |     5 | 11080 |    11   (0)| 00:00:01 |
|   2 |   BITMAP CONVERSION TO ROWIDS       |              |       |       |            |          |
|   3 |    BITMAP AND                       |              |       |       |            |          |
|   4 |     BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|   5 |      SORT ORDER BY                  |              |       |       |            |          |
|*  6 |       DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|   7 |     BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|   8 |      SORT ORDER BY                  |              |       |       |            |          |
|*  9 |       DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access("CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'HASPATH(/timestampRequestUtc)')>0 AND "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(THINTS00R45B455X)')>0)
   9 - access("CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(THINTS00R45B455X)')>0)


Statistics
----------------------------------------------------------
        578  recursive calls
          0  db block gets
     169469  consistent gets
          4  physical reads
     141412  redo size
       3021  bytes sent via SQL*Net to client
        428  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
          4  sorts (memory)
          0  sorts (disk)
          1  rows processed
Highlights: 
- la query è veloce; più veloce che non in INPS, dove impiega circa 22sec
Lowlights:
- il piano è teoricamente buono, il filtro 9 si applica a tutto il docset; JSON_VALUE e JSON_TEXTCONTAINS potrebbero non essere ugualmente efficaci insieme al filtro 9
*/

alter system flush buffer_cache;

prompt vista intermedia sempre da test3.sql
SELECT /*+ NO_MERGE(v2) */ *
FROM (
		SELECT JSON_DOCUMENT         
		FROM "DOCINPS" F 
		WHERE JSON_EXISTS (F."JSON_DOCUMENT", '$.timestampRequestUtc') 
		AND   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'FTTBIW42L24B647S') 
	) v2
WHERE JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
AND   JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'     
AND   JSON_TEXTCONTAINS (v2."JSON_DOCUMENT", '$', 'FTTBIW42L24B647S') 
/

/*
Elapsed: 00:00:43.54

Execution Plan
----------------------------------------------------------
Plan hash value: 2101691932

-----------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |              |     1 |  4102 |    11   (0)| 00:00:01 |
|   1 |  VIEW                                |              |     1 |  4102 |    11   (0)| 00:00:01 |
|*  2 |   TABLE ACCESS BY INDEX ROWID BATCHED| DOCINPS      |     1 |  2216 |    11   (0)| 00:00:01 |
|   3 |    BITMAP CONVERSION TO ROWIDS       |              |       |       |            |          |
|   4 |     BITMAP AND                       |              |       |       |            |          |
|   5 |      BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|   6 |       SORT ORDER BY                  |              |       |       |            |          |
|*  7 |        DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|   8 |      BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|   9 |       SORT ORDER BY                  |              |       |       |            |          |
|* 10 |        DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(JSON_VALUE("JSON_DOCUMENT" /*+ LOB_BY_VALUE */  FORMAT OSON ,
              '$.timestampRequestUtc' RETURNING VARCHAR2(4000) NULL ON
              ERROR)>='1970-01-01T00:00:00.0000000' AND JSON_VALUE("JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              FORMAT OSON , '$.timestampRequestUtc' RETURNING VARCHAR2(4000) NULL ON
              ERROR)<='9999-12-31T00:00:00.0000000')
   7 - access("CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'HASPATH(/timestampRequestUtc)')>0 AND "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(FTTBIW42L24B647S)')>0)
  10 - access("CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(FTTBIW42L24B647S)')>0)


Statistics
----------------------------------------------------------
        602  recursive calls
          8  db block gets
     169493  consistent gets
          8  physical reads
     142400  redo size
       3001  bytes sent via SQL*Net to client
        428  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
          4  sorts (memory)
          0  sorts (disk)
          1  rows processed

Highlights: 
- la query è veloce; più veloce che non in INPS, dove impiega la stessa durata della precedene, ovvero 22sec
Lowlights:
- il piano è teoricamente buono, il filtro 10 si applica a tutto il docset; JSON_VALUE e JSON_TEXTCONTAINS potrebbero non essere ugualmente efficaci insieme al filtro 7
--> provare nomerge ulteriore, per separare JSON_VALUE e JSON_TEXTCONTAINS

*/
alter system flush buffer_cache;

prompt query di verifica: se è possibile separare JSON_VALUE e JSON_TEXTCONTAINS
SELECT /*+ NO_MERGE(v3) */ *
FROM 
(
	SELECT JSON_DOCUMENT        
	FROM "DOCINPS" F 
	WHERE   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O')
) v3
WHERE JSON_EXISTS(v3.JSON_DOCUMENT, '$.timestampRequestUtc');

/*
Elapsed: 00:00:43.87

Execution Plan
----------------------------------------------------------
Plan hash value: 2101691932

-----------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |              |     1 |  4102 |    11   (0)| 00:00:01 |
|   1 |  VIEW                                |              |     1 |  4102 |    11   (0)| 00:00:01 |
|*  2 |   TABLE ACCESS BY INDEX ROWID BATCHED| DOCINPS      |     1 |  2216 |    11   (0)| 00:00:01 |
|   3 |    BITMAP CONVERSION TO ROWIDS       |              |       |       |            |          |
|   4 |     BITMAP AND                       |              |       |       |            |          |
|   5 |      BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|   6 |       SORT ORDER BY                  |              |       |       |            |          |
|*  7 |        DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
|   8 |      BITMAP CONVERSION FROM ROWIDS   |              |       |       |            |          |
|   9 |       SORT ORDER BY                  |              |       |       |            |          |
|* 10 |        DOMAIN INDEX                  | DOCINPS_IDX1 |       |       |     4   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(JSON_EXISTS2("JSON_DOCUMENT" /*+ LOB_BY_VALUE */  FORMAT OSON ,
              '$.timestampRequestUtc' FALSE ON ERROR)=1)
   7 - access("CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(HASPATH(/timestampRequestUtc))')>0 AND "CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(BXNXPU27H42C698O)')>0)
  10 - access("CTXSYS"."CONTAINS"("F"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(BXNXPU27H42C698O)')>0)

Highlights
- piano teoricamente OK.
Lowlights:
- al filtro 7, compare l'operazione di HASPATH che evidentemente fa peggiorare le performance

Non cambia neanche se viene scritta cosi':
SELECT /*+ NO_MERGE(v3) */ *
FROM 
(
	SELECT JSON_DOCUMENT        
	FROM "DOCINPS" F 
	WHERE   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O')
) v3
WHERE JSON_EXISTS(v3.JSON_DOCUMENT, '$.timestampRequestUtc')
AND   JSON_TEXTCONTAINS (v3."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O');
ovvero con la clausola pleonastica sul CF al livello di v3

oppure così:

	SELECT JSON_DOCUMENT        
	FROM "DOCINPS" F 
	WHERE   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'BXNXPU27H42C698O')
	AND  JSON_VALUE(F.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
	
o così:
SELECT /*+ NO_MERGE(v2) */ *
FROM (
		SELECT JSON_DOCUMENT         
		FROM "DOCINPS" F 
		WHERE JSON_EXISTS (F."JSON_DOCUMENT", '$.timestampRequestUtc') 
		AND   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'FTTBIW42L24B647S') 
	) v2
WHERE  JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
*/

-- se si rinuncia al timestamp:
-- può essere riscritta cosi'
alter system flush buffer_cache;

SELECT /*+ NO_MERGE(v)  */ *
FROM 
(
    SELECT JSON_DOCUMENT        
    FROM "DOCINPS" F 
    WHERE   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'SIOEDL01E52H445P')
) v
WHERE 
    (
           JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscale', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfTut_AMM_RL', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleRichiedente', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.informazioniDid.codiceFiscale', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfRichiedente', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CFRichiedente', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiTutore.cfTutore', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleBeneficiario', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscale', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.ComponenteFamiliare_CF', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscaleRichiedente', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleInadempiente', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscale', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscaleAggiornato', 'SIOEDL01E52H445P')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'SIOEDL01E52H445P')
    );


set autotrace off
spool off

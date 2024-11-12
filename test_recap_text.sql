set lines 132 pages 999 time on timing on
-- crea l'indice
-- text_value e non text 
alter index docinps_IDX1 noparallel;
DROP INDEX docinps_IDX1;
-- server taaaaanto temp tablespace...
CREATE INDEX docinps_IDX1 ON docinps (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text_value  dataguide off') PARALLEL 4;
alter index docinps_IDX1 noparallel;
select count(1) from docinps;
select codice_fiscale from codice_fiscale where id=1000000;
spool off

spool test_recap_text_value
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
prompt test_recap, tutte le query da docinps
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

-- aggiornamento 02-sep-2024 -- quanto sopra risale al 9 agosto
-- Cambia se non ci sono le clausole su timestampRequestUtc
-- scoperto in 23c.
-- v. file test_recap_text_test23c.sql
-- passa a DOCINPS perché ha documenti a sufficienza.

-- questa ha il piano sbagliato ed è la query originale:
alter system flush buffer_cache;
SELECT * FROM DOCINPS
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      --AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'SIOEDL01E52H445P' ) ) -- pleonastica: ma serve per indirizzare le OR successive
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
-->^C dopo oltre un minuto

-- questa è senza il timestamp -- e senza la clausola pleonastica
alter system flush buffer_cache;
SELECT * FROM DOCINPS
WHERE
    (/*     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      --AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'SIOEDL01E52H445P' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND */( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'SIOEDL01E52H445P' )
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
--> 2"

-- prova a prendere il piano buono con first_rows con la query originale
alter system flush buffer_cache;
SELECT  /*+ FIRST_ROWS(10) */ * FROM DOCINPS
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      --AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'SIOEDL01E52H445P' ) ) -- pleonastica: ma serve per indirizzare le OR successive
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
-->2min 50secs
-->non va.

-- se mi porto le statistiche buone come da nota: 2701368.1
/* 

################################
# Sul sorgente delle statistiche
# trasferisce le stats dalla 23:
[oracle@test23c ~]$  sqlplus appl1/DataBase__21c@test23c
-- come APPL1

def TAB="FRA"

col table_name for a32
col partition_name for a32
set lines 132 pages 999

-- verifica stats della tavola
select table_name, partition_name, num_rows, last_analyzed 
from   user_tab_statistics
where  table_name ='&&TAB'
order  by 1, 2;

	TABLE_NAME                       PARTITION_NAME                     NUM_ROWS LAST_ANAL
	-------------------------------- -------------------------------- ---------- ---------
	FRA                                                                        6 28-AUG-24


-- 1. Create table to hold statistics.
-- verifica esistenza STATTAB
desc STATTAB
-- crea la tavola se non esiste
exec dbms_stats.create_stat_table(user,'STATTAB');
delete STATTAB;
commit;

-- 2. Export source statistics by DBMS_STATS.EXPORT_XXXX_STATS.
SELECT * FROM USER_TAB_COL_STATISTICS WHERE TABLE_NAME = 'FRA';
SELECT * FROM USER_TAB_STATISTICS WHERE TABLE_NAME = 'FRA';

EXEC DBMS_STATS.EXPORT_TABLE_STATS(user,'&&TAB','','STATTAB');

3. Export the table holding the statistics
!expdp APPL1@test23c dumpfile=STATTAB.dmp tables=STATTAB version=21 exclude=statistics

	Export: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Sep 3 14:54:40 2024
	Version 23.5.0.24.07

	Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
	Password:

	Connected to: Oracle Database 23ai EE High Perf Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
	Starting "APPL1"."SYS_EXPORT_TABLE_01":  APPL1/********@test23c dumpfile=STATTAB.dmp tables=STATTAB
	Processing object type TABLE_EXPORT/TABLE/TABLE_DATA
	Processing object type TABLE_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
	Processing object type TABLE_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
	Processing object type TABLE_EXPORT/TABLE/TABLE
	Processing object type TABLE_EXPORT/TABLE/INDEX/INDEX
	. . exported "APPL1"."STATTAB"                            18.5 KB       1 rows
	ORA-39173: Encrypted data has been stored unencrypted in dump file set.
	Master table "APPL1"."SYS_EXPORT_TABLE_01" successfully loaded/unloaded
	******************************************************************************
	Dump file set for APPL1.SYS_EXPORT_TABLE_01 is:
	  /u01/app/oracle/product/23.0.0.0/dbhome_1/rdbms/log/20A82982E11E0C84E063C701000A16F8/STATTAB.dmp
	Job "APPL1"."SYS_EXPORT_TABLE_01" successfully completed at Tue Sep 3 14:55:19 2024 elapsed 0 00:00:33

-- copia il file in /tmp e lo rende leggibile per il trasferimento a destinazione
!cp /u01/app/oracle/product/23.0.0.0/dbhome_1/rdbms/log/20A82982E11E0C84E063C701000A16F8/STATTAB.dmp /tmp
!chmod a+r /tmp/STATTAB.dmp

######################################
# Sulla destinazione delle statistiche

rm /tmp/STATTAB.dmp
scp test23c:/tmp/STATTAB.dmp /tmp
ls -ltra /tmp/STATTAB.dmp
ssh t21c sudo chmod 777 /tmp/STATTAB.dmp
scp /tmp/STATTAB.dmp t21c:/tmp/.

ssh t21c sudo chmod a+r /tmp/STATTAB.dmp
chown oracle:oinstall /tmp/STATTAB.dmp

sqlplus appl1/DataBase__21c@pdb1

set lines 132 pages 9999
col directory_name for a21
col directory_path for a88
select directory_name, directory_path from dba_directories where directory_name='DATA_PUMP_DIR';

	DIRECTORY_NAME        DIRECTORY_PATH
	--------------------- ----------------------------------------------------------------------------------------
	DATA_PUMP_DIR         /u01/app/oracle/homes/OraDB21000_home1/rdbms/log/EDFC0B688F153F5CE053B901000A8BF5

!cp /tmp/STATTAB.dmp /u01/app/oracle/homes/OraDB21000_home1/rdbms/log/EDFC0B688F153F5CE053B901000A8BF5

-- 4. Import the table holding statistics into the target schema of target environment.
-- se c'e' bisogno di upgradere il dst, seguire il manuale per il CDB:
-- https://docs.oracle.com/en/database/oracle/oracle-database/21/nlspg/datetime-data-types-and-time-zone-support.html#GUID-8815B03F-473E-4E77-919B-7A3066442C21
-- e la nota 2794739.1 per tutti i pdb.

!impdp appl1@pdb1 dumpfile=STATTAB.dmp

	Import: Release 21.0.0.0.0 - Production on Tue Sep 3 16:15:52 2024
	Version 21.14.0.0.0

	Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.
	Password:

	Connected to: Oracle Database 21c EE High Perf Release 21.0.0.0.0 - Production
	Master table "APPL1"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
	Starting "APPL1"."SYS_IMPORT_FULL_01":  appl1/********@pdb1 dumpfile=STATTAB.dmp
	Processing object type TABLE_EXPORT/TABLE/TABLE
	Processing object type TABLE_EXPORT/TABLE/TABLE_DATA
	. . imported "APPL1"."STATTAB"                           18.52 KB       1 rows
	Processing object type TABLE_EXPORT/TABLE/INDEX/INDEX
	Job "APPL1"."SYS_IMPORT_FULL_01" successfully completed at Tue Sep 3 16:18:11 2024 elapsed 0 00:01:36

-- verifica le stats:
set lines 132
col c1 for a22
col c5 for a22
select c1, c5, count(1) conta from stattab group by c1,c5;

	SQL> select c1, c5, count(1) conta from stattab group by c1,c5;

	C1                     C5                          CONTA
	---------------------- ---------------------- ----------
	FRA                    APPL1                           1


-- 5. Update source schema, table, index, column, partition name to target schema, table, index, column, partition name.
update stattab set c1 = 'DOCINPS' where c1 = 'FRA' AND C5='APPL1';
commit;

	SQL> update stattab set c1 = 'DOCINPS' where c1 = 'FRA' AND C5='APPL1';

	1 row updated.

	SQL> commit;

	Commit complete.

-- associa le stats a destinazione (21c)

def TAB="DOCINPS"

-- verifica esistenza STATTAB
desc STATTAB
-- crea la tavola se non esiste
exec dbms_stats.create_stat_table(user,'STATTAB');
delete STATTAB;
commit;

-- preserva le stat salvandole
select count(1) from stattab;
exec dbms_stats.export_table_stats(user,'&&TAB',NULL,'STATTAB');
col c1 for a32
select c1, count(1) from STATTAB group by c1;

-- 6. Import the statstics to dictionary.
-- prima vanno cancellate le statistiche che ci sono; se necessario si possono salvare:
SELECT * FROM USER_TAB_STATISTICS WHERE TABLE_NAME = 'DOCINPS';
SELECT * FROM USER_TAB_COL_STATISTICS WHERE TABLE_NAME = 'DOCINPS';
EXEC DBMS_STATS.DELETE_TABLE_STATS(user, 'DOCINPS');
commit;

EXEC DBMS_STATS.IMPORT_SCHEMA_STATS(user, 'STATTAB');

	SQL> EXEC DBMS_STATS.IMPORT_SCHEMA_STATS(user, 'STATTAB');

	PL/SQL procedure successfully completed.


-- 7. Confirm the statistics from dictionary views.
SELECT * FROM USER_TAB_STATISTICS WHERE TABLE_NAME = 'DOCINPS';
SELECT * FROM USER_TAB_COL_STATISTICS WHERE TABLE_NAME = 'DOCINPS';
SELECT * FROM USER_TAB_COL_STATISTICS WHERE TABLE_NAME = 'DOCINPS' AND COLUMN_NAME = 'ID';

	...
	
-- prova la query
set autotrace trace

alter system flush buffer_cache;
SELECT   * FROM DOCINPS
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
--> Funziona! lock statistiche!
exec DBMS_STATS.LOCK_TABLE_STATS ('APPL1','DOCINPS');
commit;

-- Prova senza statistiche -- solo 21c
exec DBMS_STATS.UNLOCK_TABLE_STATS ('APPL1','DOCINPS');
SELECT * FROM USER_TAB_STATISTICS WHERE TABLE_NAME = 'DOCINPS';
SELECT * FROM USER_TAB_COL_STATISTICS WHERE TABLE_NAME = 'DOCINPS';
EXEC DBMS_STATS.DELETE_TABLE_STATS(user, 'DOCINPS');
SELECT * FROM USER_TAB_STATISTICS WHERE TABLE_NAME = 'DOCINPS';
SELECT * FROM USER_TAB_COL_STATISTICS WHERE TABLE_NAME = 'DOCINPS';
commit;


set autotrace trace

alter system flush buffer_cache;
SELECT   * FROM DOCINPS
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
--> non va!

*/

set autotrace off
spool off

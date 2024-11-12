set lines 132 pages 999 time on timing on
spool test_recap_text_HCC_PART_test23c

/*
SQL> select codice_fiscale from codice_fiscale where id>1000001 and rownum<=10;

CODICE_FISCALE
----------------
YZOXMB45S40D702E
LATBUW15B28B024V
ZWGXZJ81P38D318X
LATBUW15B28B024V
EALUGO76M48C605D
VJQTIT85H49C875D
FGMZSK92E09B102J
LTHBEO42E38P184X
PXGBEQ05P36A884V
MRKXTB49L26A846H

*/
prompt query originale:
set autotrace trace
prompt test_recap, tutte le query da FRA_HCC_PART (compressa HCC for query low e partizionata)
alter system flush buffer_cache;
prompt query originale
SELECT * FROM FRA_HCC_PART
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      -- AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'LATBUW15B28B024V' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'LATBUW15B28B024V')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'LATBUW15B28B024V')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'LATBUW15B28B024V')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'LATBUW15B28B024V')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'LATBUW15B28B024V')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'LATBUW15B28B024V' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'LATBUW15B28B024V' ) 
          )
    )
;
-->67secs


prompt query con singola clausola pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA_HCC_PART
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'EALUGO76M48C605D' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'EALUGO76M48C605D' ) 
          )
    )
;
-->72secs






prompt query con doppia clausola pleonastica che ha il piano buono anche in INPS ma performance non buone in INPS, uguali alle query qui sopra, oltre il minuto:
SELECT /*+ NO_MERGE(v) MONITOR GATHER_PLAN_STATISTICS */ * 
FROM (
        SELECT /*+ NO_MERGE(v2) */ *
        FROM (
                SELECT JSON_DOCUMENT         
                FROM "FRA_HCC_PART" F 
                WHERE JSON_EXISTS (F."JSON_DOCUMENT", '$.timestampRequestUtc') 
                AND   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'LATBUW15B28B024V') 
            ) v2
        WHERE JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
        AND   JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'     
        AND   JSON_TEXTCONTAINS (v2."JSON_DOCUMENT", '$', 'LATBUW15B28B024V') 
      ) v
WHERE 
    (
           JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscale', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfTut_AMM_RL', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleRichiedente', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.informazioniDid.codiceFiscale', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.cfRichiedente', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CFRichiedente', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiTutore.cfTutore', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleBeneficiario', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscale', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.ComponenteFamiliare_CF', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.CodiceFiscaleRichiedente', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.codiceFiscaleInadempiente', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscale', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.request.anagrafica.codiceFiscaleAggiornato', 'LATBUW15B28B024V')
        OR JSON_TEXTCONTAINS(v.JSON_DOCUMENT, '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'LATBUW15B28B024V')
    );
--> 46secs 


prompt query solo Text (no JSON), anche nota come s2.SQL
alter system flush buffer_cache;
SELECT /*+ MONITOR GATHER_PLAN_STATISTICS */ * FROM "FRA_HCC_PART"
WHERE JSON_TEXTCONTAINS(JSON_DOCUMENT, '$', 'LATBUW15B28B024V')
/

/*
12:18:54 SQL> 12:18:54   2  12:18:54   3
Elapsed: 00:00:00.03

Execution Plan
----------------------------------------------------------
Plan hash value: 667837806

-----------------------------------------------------------------------------------------------
| Id  | Operation                      | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |              | 15000 |    25M|  4042   (1)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID   | FRA_HCC_PART      | 15000 |    25M|  4042   (1)| 00:00:01 |
|   2 |   SORT CLUSTER BY ROWID BATCHED|              |       |       |     4   (0)| 00:00:01 |
|*  3 |    DOMAIN INDEX                | FRA_HCC_PART_IDX1 |       |       |     4   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("CTXSYS"."CONTAINS"("FRA_HCC_PART"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(LATBUW15B28B024V)')>0)


Statistics
----------------------------------------------------------
        157  recursive calls
          0  db block gets
        185  consistent gets
         56  physical reads
       4208  redo size
       4679  bytes sent via SQL*Net to client
        669  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          3  sorts (memory)
          0  sorts (disk)
          2  rows processed

Highlights: 
- immediata (notare il che codice fiscale è nuovo, mai interrogato);  veloce anche in INPS, dove impiega 1.4 secs
- notevole la differenza di tempo con INPS, 2 ordini di grandezza: secondi vs centesimi

*/

prompt query JSON solo TEXTCONTAINS, anche nota come s3
alter system flush buffer_cache;
SELECT /*+ MONITOR GATHER_PLAN_STATISTICS */ * FROM "FRA_HCC_PART"
WHERE CONTAINS ("FRA_HCC_PART"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */,'(LATBUW15B28B024V)')>0;
/*

Elapsed: 00:00:00.05

Execution Plan
----------------------------------------------------------
Plan hash value: 667837806

-----------------------------------------------------------------------------------------------
| Id  | Operation                      | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |              | 15000 |    25M|  4042   (1)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID   | FRA_HCC_PART      | 15000 |    25M|  4042   (1)| 00:00:01 |
|   2 |   SORT CLUSTER BY ROWID BATCHED|              |       |       |     4   (0)| 00:00:01 |
|*  3 |    DOMAIN INDEX                | FRA_HCC_PART_IDX1 |       |       |     4   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("CTXSYS"."CONTAINS"("FRA_HCC_PART"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(LATBUW15B28B024V)')>0)


Statistics
----------------------------------------------------------
        151  recursive calls
          0  db block gets
        185  consistent gets
         55  physical reads
       4288  redo size
       4679  bytes sent via SQL*Net to client
        669  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          3  sorts (memory)
          0  sorts (disk)
          2  rows processed

Highlights: 
- immediata (notare il che codice fiscale è sempre nuovo, mai interrogato);  veloce anche in INPS, dove impiega 1.3 secs
- notevole la differenza di tempo con INPS, 2 ordini di grandezza: secondi vs centesimi

*/

prompt vista più interna con JSON_VALUE, da test3 query 1
alter system flush buffer_cache;
SELECT JSON_DOCUMENT         
FROM "FRA_HCC_PART" F 
WHERE JSON_EXISTS (F."JSON_DOCUMENT", '$.timestampRequestUtc') 
AND   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'LATBUW15B28B024V') 
/
--> 74secs

prompt vista intermedia sempre da test3.sql
alter system flush buffer_cache;
SELECT /*+ NO_MERGE(v2) */ *
FROM (
		SELECT JSON_DOCUMENT         
		FROM "FRA_HCC_PART" F 
		WHERE JSON_EXISTS (F."JSON_DOCUMENT", '$.timestampRequestUtc') 
		AND   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'LATBUW15B28B024V') 
	) v2
WHERE JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' 
AND   JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'     
AND   JSON_TEXTCONTAINS (v2."JSON_DOCUMENT", '$', 'LATBUW15B28B024V') 
/
--> 84secs

prompt query di verifica: se è possibile separare JSON_VALUE e JSON_TEXTCONTAINS
alter system flush buffer_cache;
SELECT /*+ NO_MERGE(v3) */ *
FROM 
(
	SELECT JSON_DOCUMENT        
	FROM "FRA_HCC_PART" F 
	WHERE   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'LATBUW15B28B024V')
) v3
WHERE JSON_EXISTS(v3.JSON_DOCUMENT, '$.timestampRequestUtc');
--> 74 secs

prompt come sopra ma riscritta con la clausola pleonastica sul CF al livello di v3:
alter system flush buffer_cache;
SELECT /*+ NO_MERGE(v3) */ *
FROM 
(
	SELECT JSON_DOCUMENT        
	FROM "DOCINPS" F 
	WHERE   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'LATBUW15B28B024V')
) v3
WHERE JSON_EXISTS(v3.JSON_DOCUMENT, '$.timestampRequestUtc')
AND   JSON_TEXTCONTAINS (v3."JSON_DOCUMENT", '$', 'LATBUW15B28B024V');
--> 48secs

prompt come sopra ma riscritta di nuovo:
alter system flush buffer_cache;

SELECT JSON_DOCUMENT        
FROM "DOCINPS" F 
WHERE   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'LATBUW15B28B024V')
AND  JSON_VALUE(F.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000';
--> 47secs

prompt e di nuovo 
alter system flush buffer_cache;
SELECT /*+ NO_MERGE(v2) */ *
FROM (
		SELECT JSON_DOCUMENT         
		FROM "DOCINPS" F 
		WHERE JSON_EXISTS (F."JSON_DOCUMENT", '$.timestampRequestUtc') 
		AND   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'LATBUW15B28B024V') 
	) v2
WHERE  JSON_VALUE(v2.JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000';
--> 52secs

prompt query senza clausola pleonastica e senza filtro su timestampRequestUtc
alter system flush buffer_cache;
SELECT * FROM FRA_HCC_PART
WHERE
    ( /*    JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND  ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'EALUGO76M48C605D' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND  */( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'EALUGO76M48C605D' ) 
          )
    )
;
-->veloce: questo probabilmente risolve il problema originato dal fatto che la forma HCC_PART ha storage limitato.
set autotrace off
spool off

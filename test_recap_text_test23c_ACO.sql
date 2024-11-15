set lines 132 pages 999 time on timing on
spool test_recap_text_test23c

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

SQL> select count(1) from FRA;

   COUNT(1)
___________
   29999996
   
SQL> select sum(bytes)/1024/1024/1024 GB from user_segments where segment_name='FRA';

                  GB 
____________________ 
   58.49810791015625 

*/
-- query originale:
set autotrace trace
prompt test_recap, tutte le query da FRA (compressa ACO)
alter system flush buffer_cache;
prompt query originale
SELECT * FROM FRA
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
-->^C dopo più di un minuto


prompt query con singola clausola pleonastica
alter system flush buffer_cache;
SELECT * FROM FRA
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
/*
20:20:13 SQL> prompt query con singola clausola pleonastica
query con singola clausola pleonastica
20:20:18 SQL> alter system flush buffer_cache;

System altered.

Elapsed: 00:00:00.23
20:20:21 SQL> SELECT * FROM FRA
WHERE
20:20:27   2  20:20:27   3      (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'EALUGO76M48C605D' ) ) -- pleonastica: ma serve per indirizzare le OR successive
20:20:27   4  20:20:27   5        AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'EALUGO76M48C605D' )
20:20:27   6                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'EALUGO76M48C605D' )
20:20:27   7  20:20:27   8                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'EALUGO76M48C605D' )
20:20:27   9                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'EALUGO76M48C605D' )
20:20:27  10                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'EALUGO76M48C605D')
20:20:27  11  20:20:27  12                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'EALUGO76M48C605D')
20:20:27  13                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'EALUGO76M48C605D')
20:20:28  14                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'EALUGO76M48C605D')
20:20:28  15                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'EALUGO76M48C605D' )
20:20:28  16                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'EALUGO76M48C605D')
20:20:28  17  20:20:28  18                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'EALUGO76M48C605D' )
20:20:28  19                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'EALUGO76M48C605D' )
20:20:28  20                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'EALUGO76M48C605D' )
20:20:28  21                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'EALUGO76M48C605D' )
20:20:28  22                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'EALUGO76M48C605D' )
20:20:28  23  20:20:28  24                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'EALUGO76M48C605D' )
20:20:28  25                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'EALUGO76M48C605D' )
          )
    )
20:20:28  26  20:20:28  27  20:20:28  28  ;

Elapsed: 00:00:00.37

Execution Plan
----------------------------------------------------------
Plan hash value: 354579338

----------------------------------------------------------------------------------------
| Id  | Operation                   | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |          |     1 |  1786 |     4   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| FRA      |     1 |  1786 |     4   (0)| 00:00:01 |
|*  2 |   DOMAIN INDEX              | FRA_IDX1 |       |       |     4   (0)| 00:00:01 |
----------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(JSON_VALUE("JSON_DOCUMENT" /*+ LOB_BY_VALUE */  FORMAT OSON ,
              '$.timestampRequestUtc' RETURNING VARCHAR2(4000) NULL ON ERROR TYPE(LAX)
              )>='1970-01-01T00:00:00.0000000' AND JSON_VALUE("JSON_DOCUMENT" /*+
              LOB_BY_VALUE */  FORMAT OSON , '$.timestampRequestUtc' RETURNING VARCHAR2(4000)
              NULL ON ERROR TYPE(LAX) )<='9999-12-31T00:00:00.0000000' AND
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'HASPATH(/timestampRequestUtc)')>0 AND
              ("CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/cfTut_AMM_RL)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/codiceFiscaleRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/informazioniDid/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/cfRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/CFRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/esitoElaborazione/esitiINPS/nucleoISEEDell
              aDomanda/soggettiNucleo)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(EALUGO76M48C605D) INPATH
              (/request/esitoElaborazione/estremiDomanda/datiTutore/cfTutore)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/esitoElaborazione/estremiDomanda/datiRichi
              edente/cfRichiedente)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(EALUGO76M48C605D) INPATH
              (/request/esitiINPS/nucleoISEEDellaDomanda/soggettiNucleo)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/estremiDomanda/datiTutore/cfTutore)')>0
              OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/estremiDomanda/datiRichiedente/cfRichieden
              te)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/response/payload/lavoratore/datiAnagrafici/codiceF
              iscale)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/codiceFiscaleBeneficiario)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/CodiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/ComponenteFamiliare_CF)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/CodiceFiscaleRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/codiceFiscaleInadempiente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/anagrafica/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/request/anagrafica/codiceFiscaleAggiornato)')>0
              OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D) INPATH (/response/mlpsResponse/esitoAnagrafica/codiceFiscal
              e)')>0))
   2 - access("CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(EALUGO76M48C605D)')>0)


Statistics
----------------------------------------------------------
       5317  recursive calls
          0  db block gets
       5589  consistent gets
        658  physical reads
      50368  redo size
       4639  bytes sent via SQL*Net to client
        669  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
         10  sorts (memory)
          0  sorts (disk)
          2  rows processed

20:20:30 SQL> set autot off
20:20:39 SQL> SELECT * FROM FRA
WHERE
20:20:41   2  20:20:41   3      (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
20:20:41   4        AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'EALUGO76M48C605D' ) ) -- pleonastica: ma serve per indirizzare le OR successive
20:20:41   5        AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'EALUGO76M48C605D' )
20:20:41   6                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'EALUGO76M48C605D' )
20:20:41   7  20:20:41   8                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'EALUGO76M48C605D' )
20:20:41   9                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'EALUGO76M48C605D' )
20:20:41  10                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'EALUGO76M48C605D20:20:41  11  ')
20:20:41  12                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'EALUGO76M48C605D')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cf20:20:41  13  Richiedente', 'EALUGO76M48C605D')
20:20:41  14                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'EALUGO76M48C605D')
20:20:41  15                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'EALUGO76M48C605D20:20:41  16  ' )
20:20:41  17                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'EALUGO76M48C605D')
20:20:41  18                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'EALUGO76M48C605D' )
20:20:41  19  20:20:41  20                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'EALUGO76M48C605D' )
20:20:41  21                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'EALUGO76M48C605D' )
20:20:41  22                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'EALUGO76M48C605D' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'EALUGO76M48C605D' )
20:20:41  23  20:20:41  24                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'EALUGO76M48C605D' )
20:20:41  25                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'EALUGO76M48C605D' )
20:20:41  26            )
    )
;20:20:41  27  20:20:41  28

ID
------------------------------------------------------------------------------------------------------------------------------------
TIMESTAMPREQUESTUTC
---------------------------------------------------------------------------
LAST_MODIFIED
---------------------------------------------------------------------------
VERSION
------------------------------------------------------------------------------------------------------------------------------------
JSON_DOCUMENT
--------------------------------------------------------------------------------
1000006
27-JUN-21 01.21.54.043434 PM
27-JUN-21 01.21.54.043434 PM
1
{"_id":"h3z8xbdou37n6kupwu5sbmje","codiceFlusso":"H-FXW-DNZ-INPS-SIISLDI-3267","

1000006
27-JUN-21 01.21.54.043434 PM
27-JUN-21 01.21.54.043434 PM
1
{"_id":"h3z8xbdou37n6kupwu5sbmje","codiceFlusso":"H-FXW-DNZ-INPS-SIISLDI-3267","


Elapsed: 00:00:00.07

*/

set autotrace off
spool off

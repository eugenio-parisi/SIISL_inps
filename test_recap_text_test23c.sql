set lines 132 pages 999 time on timing on
spool test_recap_text_test23c

/*
SQL> select codice_fiscale from codice_fiscale where id>1000001 and rownum<=10;

CODICE_FISCALE
----------------
YZOXMB45S40D702E
KKHVTJ09L24P835G
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
prompt test_recap, tutte le query da FRA (non compressa)
alter system flush buffer_cache;
prompt query originale
SELECT * FROM FRA
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
      -- AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'KKHVTJ09L24P835G' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'KKHVTJ09L24P835G')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'KKHVTJ09L24P835G')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'KKHVTJ09L24P835G')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'KKHVTJ09L24P835G')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'KKHVTJ09L24P835G')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'KKHVTJ09L24P835G' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'KKHVTJ09L24P835G' ) 
          )
    )
;
--> 26secs o peggio: piano errato  Plan hash value: 4148946819


prompt query con singola clausola pleonastica
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
/*
15:34:45 SQL> prompt query con singola clausola pleonastica
query con singola clausola pleonastica
15:34:49 SQL> alter system flush buffer_cache;

System altered.

Elapsed: 00:00:00.30
15:34:53 SQL> SELECT * FROM FRA
WHERE
15:35:00   2  15:35:00   3      (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
15:35:00   4        AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
      AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
15:35:00   5  15:35:00   6                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
15:35:00   7                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
15:35:00   8  15:35:00   9                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
15:35:00  10                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
15:35:00  11                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
15:35:00  12                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedent15:35:00  13  e.cfRichiedente', 'YZOXMB45S40D702E')
15:35:00  14                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
15:35:00  15                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
15:35:00  16  15:35:00  17  15:35:00  18                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
15:35:00  19                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
15:35:00  20                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
15:35:00  21                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
15:35:00  22                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
15:35:00  23  15:35:00  24                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
15:35:00  25                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
          )
    )
15:35:00  26  15:35:00  27  15:35:00  28  ;

Elapsed: 00:00:00.40

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
              ,'(YZOXMB45S40D702E) INPATH (/request/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/cfTut_AMM_RL)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/codiceFiscaleRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/informazioniDid/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/cfRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/CFRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/esitoElaborazione/esitiINPS/nucleoISEEDell
              aDomanda/soggettiNucleo)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(YZOXMB45S40D702E) INPATH
              (/request/esitoElaborazione/estremiDomanda/datiTutore/cfTutore)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/esitoElaborazione/estremiDomanda/datiRichi
              edente/cfRichiedente)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(YZOXMB45S40D702E) INPATH
              (/request/esitiINPS/nucleoISEEDellaDomanda/soggettiNucleo)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/estremiDomanda/datiTutore/cfTutore)')>0
              OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/estremiDomanda/datiRichiedente/cfRichieden
              te)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/response/payload/lavoratore/datiAnagrafici/codiceF
              iscale)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/codiceFiscaleBeneficiario)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/CodiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/ComponenteFamiliare_CF)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/CodiceFiscaleRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/codiceFiscaleInadempiente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/anagrafica/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/anagrafica/codiceFiscaleAggiornato)')>0
              OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/response/mlpsResponse/esitoAnagrafica/codiceFiscal
              e)')>0))
   2 - access("CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E)')>0)


Statistics
----------------------------------------------------------
       5317  recursive calls
          0  db block gets
       5590  consistent gets
        658  physical reads
      50324  redo size
       4675  bytes sent via SQL*Net to client
        669  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
         10  sorts (memory)
          0  sorts (disk)
          2  rows processed

15:35:01 SQL> set autot off
15:38:07 SQL> r
  1  SELECT * FROM FRA
  2  WHERE
  3      (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
  4        AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
  5        AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
  6                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
  7                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
  8                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
  9                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
 10                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
 11                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
 12                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
 13                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
 14                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
 15                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' )
 16                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
 17                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
 18                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
 19                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
 20                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
 21                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
 22                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
 23                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
 24                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
 25                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
 26            )
 27      )
 28*

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
1000002
27-MAY-21 01.21.54.043434 PM
27-MAY-21 01.21.54.043434 PM
1
{"_id":"0vujrc4arfcusm4qb4wpwi9q","codiceFlusso":"Z-TGK-LAO-INPS-SIISLDI-9093","

1000002
27-MAY-21 01.21.54.043434 PM
27-MAY-21 01.21.54.043434 PM
1
{"_id":"0vujrc4arfcusm4qb4wpwi9q","codiceFlusso":"Z-TGK-LAO-INPS-SIISLDI-9093","


*/

/* 
attenzione:
- quanto sopra riprodotto il 28/8, ore 22:21, con il CF YZ0 e tracciato in lst 
	
		09:10:48 SQL> !ls -ltr *lst
		-rw-r--r-- 1 oracle oinstall   1261 Aug 28 15:06 insertfra.lst
		-rw-r--r-- 1 oracle oinstall   1922 Aug 28 17:31 insertfra_aco.lst
	-->	-rw-r--r-- 1 oracle oinstall  25962 Aug 28 20:21 test_recap_text_test23c.lst
		-rw-r--r-- 1 oracle oinstall 165724 Aug 29 12:34 test_recap_text_HCC_test23c.lst
	su test23c (dbcs 23ai)

con il CF EALUGO76M48C605D
- dopo le statistiche la query ruproduce un piano subotpimal:
Plan hash value: 3663702340

------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |          |     1 |  1793 |    12   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID BATCHED| FRA      |     1 |  1793 |    12   (0)| 00:00:01 |
|   2 |   BITMAP CONVERSION TO ROWIDS       |          |       |       |            |          |
|   3 |    BITMAP AND                       |          |       |       |            |          |
|   4 |     BITMAP CONVERSION FROM ROWIDS   |          |       |       |            |          |
|   5 |      SORT ORDER BY                  |          |       |       |            |          |
|*  6 |       DOMAIN INDEX                  | FRA_IDX1 |       |       |     4   (0)| 00:00:01 |
|   7 |     BITMAP CONVERSION FROM ROWIDS   |          |       |       |            |          |
|   8 |      SORT ORDER BY                  |          |       |       |            |          |
|*  9 |       DOMAIN INDEX                  | FRA_IDX1 |       |       |     4   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------


*/

prompt ripete query con singola clausola pleonastica con CF EALUGO76M48C605D per analisi
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
--> riproduce il 30/8 il piano sbagliato con hash 3663702340
/*
Esecuzioni successive al 28 agosto, es. esecuzione odierna:
SQL Id: fqgs5k48wj3fq 
SQL Execution Id: 16777216 
SQL Execution Start: 30-Aug-2024 09:04:33

verifica con script di tgorman.us 4gg indietro nel tempo:

		[oracle@test23c ~]$  sqlplus appl1/DataBase__21c@test23c

		SQL*Plus: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Fri Aug 30 09:13:22 2024
		Version 23.5.0.24.07

		Copyright (c) 1982, 2024, Oracle.  All rights reserved.

		Last Successful login time: Fri Aug 30 2024 09:08:53 +00:00

		Connected to:
		Oracle Database 23ai EE High Perf Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
		Version 23.5.0.24.07

		SQL> @a
		Enter the SQL_ID: fqgs5k48wj3fq
		Enter number of days (backwards from this hour) to report (default: ALL): 4
		+--------------------------------------------------------------------------------------------------+
		|Plan HV     Min Snap  Max Snap  Execs       LIO            PIO            CPU         Elapsed     |
		+--------------------------------------------------------------------------------------------------+
		|354579338   35        35        2           9,165          658            0.20        0.43        |
		+--------------------------------------------------------------------------------------------------+

																						 Summary Execution Statistics Over Time
																						 Avg                 Avg
		Snapshot                             Avg LIO             Avg PIO          CPU (secs)      Elapsed (secs)
		Time               Execs            Per Exec            Per Exec            Per Exec            Per Exec
		------------ ----------- ------------------- ------------------- ------------------- -------------------
		28-AUG 19:58           2            4,582.50              329.00                0.10                0.22
					 ----------- ------------------- ------------------- ------------------- -------------------
		avg                                 4,582.50              329.00                0.10                0.22
		sum                    2

																						 Per-Plan Execution Statistics Over Time
																									Avg                 Avg
			  Plan Snapshot                             Avg LIO             Avg PIO          CPU (secs)      Elapsed (secs)
		Hash Value Time               Execs            Per Exec            Per Exec            Per Exec            Per Exec
		---------- ------------ ----------- ------------------- ------------------- ------------------- -------------------
		 354579338 28-AUG 19:58           2            4,582.50              329.00                0.10                0.22
		**********              ----------- ------------------- ------------------- ------------------- -------------------
		avg                                            4,582.50              329.00                0.10                0.22
		sum                               2

		SQL> ttitle off

Questo qui sopra e' il piano buono, con hash 354579338
il .lst conferma che e' stato fatto il flush, ed infatti lo statement ha fatto PIO.

In quel momento la tavola FRA era stata probabilmente creata in giorno stesso e prima del comlpetamento del calcolo automatico delle statistiche, qiundi e senza statistiche (se non quelle di caricamento).
SQL> select to_char(created,'ddmmyyyy hh24:mi:ss') from dba_objects where object_name='FRA';

TO_CHAR(CREATED,'
-----------------
28082024 09:54:51

1 row selected.

Si può tentare di lockare le statistiche dopo aver rimesso quelle delle ore 20:00 del 28/08. Gli oggetti interessati sono (oltre a FRA):
	SQL> col object_name for a32
	SQL> set lines 100
	SQL> r
	  1  select object_id, object_name, to_char(created,'ddmmyyyy hh24:mi:ss')
	  2  from dba_objects
	  3  where object_name = 'FRA' -- table/colletion
	  4  or object_name like 'FRA_IDX%' -- json search indexes
	  5  or object_name like 'DR%FRA_I%' --json search indexes underlying structures
	  6  order by 1
	  7*

	 OBJECT_ID Name                             TO_CHAR(CREATED,'
	---------- -------------------------------- -----------------
		 71629 FRA                              28082024 09:54:51
		 72172 FRA_IDX1                         28082024 14:22:07
		 72173 DR$FRA_IDX1$I                    28082024 14:22:08
		 72176 DR$FRA_IDX1$K                    28082024 14:22:08
		 72177 DR$FRA_IDX1$N                    28082024 14:22:08
		 72178 DR$FRA_IDX1$U                    28082024 14:22:08
		 72179 DR$FRA_IDX1$Q                    28082024 14:22:08
		 72180 DR$FRA_IDX1$C                    28082024 14:22:08
		 72181 DR$FRA_IDX1$B                    28082024 14:22:08
		 72182 DR$FRA_IDX1$G                    28082024 14:22:08
		 72185 DR$FRA_IDX1$X                    28082024 14:53:48
		 72186 DR$FRA_IDX1$NI                   28082024 15:03:35
		 72187 DR$FRA_IDX1$KD                   28082024 15:03:35
		 72188 DR$FRA_IDX1$KR                   28082024 15:03:46
		 72189 DR$FRA_IDX1$UI                   28082024 15:03:57
		 72190 DR$FRA_IDX1$H                    28082024 15:03:57

	16 rows selected.

Prendendo FRA, dalla nota 761554.1
		set pages 150;
		col owner for a6
		col OBJECT_NAME for a5 hea Name
		col SUBOBJECT_NAME for a5 hea sName
		select distinct(o.owner), o.object_name, o.object_id, o.object_type, o.subobject_name,
		CASE
		  WHEN o.object_type = 'INDEX PARTITION' THEN to_char(si.savtime)
		  WHEN o.object_type = 'TABLE PARTITION' THEN to_char(st.savtime)
		  WHEN o.object_type = 'INDEX' THEN to_char(si.savtime)
		  WHEN o.object_type = 'TABLE' THEN to_char(st.savtime)
		  ELSE 'NOTHING'
		END AS "nsavtime"
		from dba_objects o, sys.WRI$_OPTSTAT_IND_HISTORY si, sys.WRI$_OPTSTAT_TAB_HISTORY st
		where (o.owner, o.object_name) in (
		select owner, index_name as object_name from dba_indexes
			where table_owner=('&&OWNER')
			and table_name in ('&&TABLE_NAME')
		   union
			select owner, table_name as object_name from dba_tables
			where owner=('&OWNER')
			and table_name in ('&TABLE_NAME'))
		and (o.object_id=si.obj#
		or o.object_id=st.obj#)
		--and si.savtime between  to_date('06-JAN-2014:10:30:00','DD-MON-YYYY:HH24:MI:SS')  and to_date('06-JAN-2014:16:10:00','DD-MON-YYYY:HH24:MI:SS')
		--and st.savtime between to_date('06-JAN-2014:10:30:00','DD-MON-YYYY:HH24:MI:SS')  and to_date('06-JAN-2014:16:10:00','DD-MON-YYYY:HH24:MI:SS')
		order by 6,4,2
		/ 
		
La query andrebbe Modificata  gli altri oggetti, solo che sys.WRI$_OPTSTAT_IND_HISTORY non ha nulla per quegli obj#, mentre la TAB_ ha esattamente tre righe per FRA:
		SQL> select obj# from sys.WRI$_OPTSTAT_IND_HISTORY si where obj# in (71629, 72172, 72173, 72176, 72177, 72178, 72179, 72180, 72181, 72182, 72185, 72186, 72187, 72188, 72189, 72190);

		no rows selected

		SQL> select obj# from sys.WRI$_OPTSTAT_TAB_HISTORY st where obj# in (71629, 72172, 72173, 72176, 72177, 72178, 72179, 72180, 72181, 72182, 72185, 72186, 72187, 72188, 72189, 72190)
		  2  /

			  OBJ#
		----------
			 71629
			 71629
			 71629

		3 rows selected.
Questa la configurazione per il restore delle stat:
	SQL> select DBMS_STATS.GET_STATS_HISTORY_RETENTION from dual;

	GET_STATS_HISTORY_RETENTION
	---------------------------
							 31

	1 row selected.

	SQL> select DBMS_STATS.GET_STATS_HISTORY_AVAILABILITY from dual;

	GET_STATS_HISTORY_AVAILABILITY
	---------------------------------------------------------------------------
	02-AUG-24 12.04.29.852124000 PM +00:00

	1 row selected.



Quindi le statistiche sono solo per FRA:
 
OWNER  Name   OBJECT_ID OBJECT_TYPE             sName nsavtime
------ ----- ---------- ----------------------- ----- -------------------------------------------------------------------------
APPL1  FRA        71629 TABLE                         28-AUG-24 01.47.26.076217 PM +00:00
APPL1  FRA        71629 TABLE                         28-AUG-24 09.57.33.766639 AM +00:00
APPL1  FRA        71629 TABLE                         28-AUG-24 10.11.05.042377 PM +00:00

Quelle buone sono le ultime o le penultime.
Prova con: 28-AUG-24 09.57.33.766639 AM +00:00
Dalla nota: 452011.1

execute DBMS_STATS.RESTORE_TABLE_STATS ('APPL1','FRA',date)

in realta' sys.WRI$_OPTSTAT_TAB_HISTORY  ha un tstamp per savtime:
 Name                                                  Null?    Type
 ----------------------------------------------------- -------- ------------------------------------
 OBJ#                                                  NOT NULL NUMBER
 SAVTIME                                                        TIMESTAMP(6) WITH TIME ZONE
...
e infatti così è la packproc:

PROCEDURE RESTORE_TABLE_STATS
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 OWNNAME                        VARCHAR2                IN
 TABNAME                        VARCHAR2                IN
 AS_OF_TIMESTAMP                TIMESTAMP WITH TIME ZONE IN
 RESTORE_CLUSTER_INDEX          BOOLEAN                 IN     DEFAULT
 FORCE                          BOOLEAN                 IN     DEFAULT
 NO_INVALIDATE                  BOOLEAN                 IN     DEFAULT
 
Ora con i TS si può anche impazzire:
		SQL> select
		 to_char(systimestamp,'DD-MON-YY HH.MI.SS.FF6 AM TZH:TZM') -- maschera per il timestamp
		,TIMESTAMP '2024-08-02 09:57:33.766639 +00:00' -- tstamp constructor
		  2    3    4  , to_timestamp ('28-AUG-24 09.57.33.766639 AM','DD-MON-YY HH.MI.SS.FF6 AM') -- tots
		from dual;  5

		TO_CHAR(SYSTIMESTAMP,'DD-MON-YYHH.MI.SS.FF6A
		--------------------------------------------
		TIMESTAMP'2024-08-0209:57:33.766639+00:00'--TSTAMPCONSTRUCTOR
		---------------------------------------------------------------------------
		TO_TIMESTAMP('28-AUG-2409.57.33.766639AM','DD-MON-YYHH.MI.SS.FF6AM')--TOTS
		---------------------------------------------------------------------------
		30-AUG-24 12.45.16.947019 PM +00:00
		02-AUG-24 09.57.33.766639000 AM +00:00
		28-AUG-24 09.57.33.766639000 AM

		1 row selected.

Quindi:
SQL> execute DBMS_STATS.RESTORE_TABLE_STATS ('APPL1','FRA','28-AUG-24 09.57.33.766639 AM +00:00');

PL/SQL procedure successfully completed.

Prova della query:
12:52:52 SQL> prompt query con singola clausola pleonastica
alter system flush buffer_cache;
query con singola clausola pleonastica
12:53:05 SQL>
System altered.

Elapsed: 00:00:00.18
12:53:05 SQL> SELECT * FROM FRA
WHERE
    (     JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') >= '1970-01-01T00:00:00.0000000' AND JSON_VALUE(JSON_DOCUMENT, '$.timestampRequestUtc') <= '9999-12-31T00:00:00.0000000'
12:53:11   2  12:53:11   3  12:53:11   4        AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$', 'YZOXMB45S40D702E' ) ) -- pleonastica: ma serve per indirizzare le OR successive
12:53:11   5        AND ( JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscale', 'YZOXMB45S40D702E' )
12:53:11   6                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfTut_AMM_RL', 'YZOXMB45S40D702E' )
12:53:11   7                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.informazioniDid.codiceFiscale', 'YZOXMB45S40D702E' )
12:53:11   8  12:53:11   9                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.cfRichiedente', 'YZOXMB45S40D702E' )
12:53:11  10                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CFRichiedente', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
12:53:11  11  12:53:11  12                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E')
12:53:12  13                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitoElaborazione.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E')
12:53:12  14                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.esitiINPS.nucleoISEEDellaDomanda.soggettiNucleo', 'YZOXMB45S40D702E')
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiTutore.cfTutore', 'YZOXMB45S40D702E' 12:53:12  15  )
12:53:12  16                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.estremiDomanda.datiRichiedente.cfRichiedente', 'YZOXMB45S40D702E' )
12:53:12  17                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.payload.lavoratore.datiAnagrafici.codiceFiscale', 'YZOXMB45S40D702E')
12:53:12  18                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleBeneficiario', 'YZOXMB45S40D702E' )
12:53:12  19                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscale', 'YZOXMB45S40D702E' )
              OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.ComponenteFamiliare_CF', 'YZOXMB45S40D702E' )
12:53:12  20  12:53:12  21                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.CodiceFiscaleRichiedente', 'YZOXMB45S40D702E' )
12:53:12  22                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.codiceFiscaleInadempiente', 'YZOXMB45S40D702E' )
12:53:12  23                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
12:53:12  24                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.request.anagrafica.codiceFiscaleAggiornato', 'YZOXMB45S40D702E' )
12:53:12  25                OR JSON_TEXTCONTAINS ( "JSON_DOCUMENT", '$.response.mlpsResponse.esitoAnagrafica.codiceFiscale', 'YZOXMB45S40D702E' )
12:53:12  26            )
    )
12:53:12  27  12:53:12  28  ;

Elapsed: 00:00:00.19

Execution Plan
----------------------------------------------------------
Plan hash value: 354579338

----------------------------------------------------------------------------------------
| Id  | Operation                   | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |          |     1 |  1788 |     4   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| FRA      |     1 |  1788 |     4   (0)| 00:00:01 |
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
              ,'(YZOXMB45S40D702E) INPATH (/request/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/cfTut_AMM_RL)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/codiceFiscaleRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/informazioniDid/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/cfRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/CFRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/esitoElaborazione/esitiINPS/nucleoISEEDell
              aDomanda/soggettiNucleo)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(YZOXMB45S40D702E) INPATH
              (/request/esitoElaborazione/estremiDomanda/datiTutore/cfTutore)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/esitoElaborazione/estremiDomanda/datiRichi
              edente/cfRichiedente)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+
              LOB_BY_VALUE */ ,'(YZOXMB45S40D702E) INPATH
              (/request/esitiINPS/nucleoISEEDellaDomanda/soggettiNucleo)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/estremiDomanda/datiTutore/cfTutore)')>0
              OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/estremiDomanda/datiRichiedente/cfRichieden
              te)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/response/payload/lavoratore/datiAnagrafici/codiceF
              iscale)')>0 OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/codiceFiscaleBeneficiario)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/CodiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/ComponenteFamiliare_CF)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/CodiceFiscaleRichiedente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/codiceFiscaleInadempiente)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/anagrafica/codiceFiscale)')>0 OR
              "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/request/anagrafica/codiceFiscaleAggiornato)')>0
              OR "CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E) INPATH (/response/mlpsResponse/esitoAnagrafica/codiceFiscal
              e)')>0))
   2 - access("CTXSYS"."CONTAINS"("FRA"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */
              ,'(YZOXMB45S40D702E)')>0)


Statistics
----------------------------------------------------------
       5317  recursive calls
          0  db block gets
       5586  consistent gets
        680  physical reads
       3580  redo size
       4675  bytes sent via SQL*Net to client
        669  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
         10  sorts (memory)
          0  sorts (disk)
          2  rows processed

Funziona!  C'e' la pleonastica!
blocco le statistiche!

exec DBMS_STATS.LOCK_TABLE_STATS ('APPL1','FRA');
commit;



*/

/* verifica le diff per queste statistiche:

APPL1  FRA        71629 TABLE                         28-AUG-24 01.47.26.076217 PM +00:00
APPL1  FRA        71629 TABLE                         28-AUG-24 09.57.33.766639 AM +00:00
APPL1  FRA        71629 TABLE                         28-AUG-24 10.11.05.042377 PM +00:00


col table_name for a22
SQL> select table_name,stats_update_time from user_tab_stats_history where table_name='FRA'

TABLE_NAME             STATS_UPDATE_TIME
---------------------- ---------------------------------------------------------------------------
FRA                    28-AUG-24 09.57.33.766639 AM +00:00
FRA                    28-AUG-24 01.47.26.076217 PM +00:00
FRA                    28-AUG-24 10.11.05.042377 PM +00:00
FRA                    30-AUG-24 12.49.11.754357 PM +00:00
FRA                    30-AUG-24 12.54.44.870426 PM +00:00



select table_name,stats_update_time from user_tab_stats_history where table_name='FRA';
select * from table (DBMS_STATS.DIFF_TABLE_STATS_IN_HISTORY (user,'FRA',systimestamp,'30-AUG-24 12.54.44.870426 PM +00:00'));
--> current vs quelle ripristinate:
	REPORT                                                                         
	-------------------------------------------------------------------------------
	###############################################################################

	STATISTICS DIFFERENCE REPORT FOR:
	.................................

	TABLE         : FRA
	OWNER         : APPL1
	SOURCE A      : Statistics as of 30-AUG-24 01.07.04.635001 PM +00:00
	SOURCE B      : Statistics as of 30-AUG-24 12.54.44.870426 PM +00:00
	PCTTHRESHOLD  : 10
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	NO DIFFERENCE IN TABLE / (SUB)PARTITION STATISTICS
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	NO DIFFERENCE IN COLUMN STATISTICS
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	NO DIFFERENCE IN INDEX / (SUB)PARTITION STATISTICS
	##############################################################################
	
select * from table (DBMS_STATS.DIFF_TABLE_STATS_IN_HISTORY (user,'FRA',systimestamp,'30-AUG-24 12.49.11.754357 PM +00:00'));
--> current con quelle precedenti alla restore:
	###############################################################################

	STATISTICS DIFFERENCE REPORT FOR:
	.................................

	TABLE         : FRA
	OWNER         : APPL1
	SOURCE A      : Statistics as of 30-AUG-24 01.08.47.518976 PM +00:00
	SOURCE B      : Statistics as of 30-AUG-24 12.49.11.754357 PM +00:00
	PCTTHRESHOLD  : 10
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	NO DIFFERENCE IN TABLE / (SUB)PARTITION STATISTICS
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	COLUMN STATISTICS DIFFERENCE:
	.............................

	COLUMN_NAME     SRC NDV     DENSITY    HIST NULLS   LEN  MIN   MAX   SAMPSIZ
	...............................................................................

	ID              A   NO_STATS
					B   1.9E+07 .000000052 NO   0       9    31    39303 3.E+07
	JSON_DOCUMENT   A   NO_STATS
					B   0       0          NO   0       1759   3.E+07
	LAST_MODIFIED   A   NO_STATS
					B   9262    .000107968 NO   0       11   78780 787C0 3.E+07
	SYS_IME_OSON_78 A   NO_STATS
					B   1       1          NO   0       2    EF    EF    3.E+07
	TIMESTAMPREQUES A   NO_STATS
					B   9262    .000107968 NO   0       11   78780 787C0 3.E+07
	VERSION         A   NO_STATS
					B   1       1          NO   0       2    31    31    3.E+07
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	NO DIFFERENCE IN INDEX / (SUB)PARTITION STATISTICS
	###############################################################################

select * from table (DBMS_STATS.DIFF_TABLE_STATS_IN_HISTORY (user,'FRA','30-AUG-24 12.49.11.754357 PM +00:00','28-AUG-24 10.11.05.042377 PM +00:00'));
--> le precedenti alla restore e il 28 a chiusura lavori (dopo la query ok):
	###############################################################################

	STATISTICS DIFFERENCE REPORT FOR:
	.................................

	TABLE         : FRA
	OWNER         : APPL1
	SOURCE A      : Statistics as of 30-AUG-24 12.49.11.754357 PM +00:00
	SOURCE B      : Statistics as of 28-AUG-24 10.11.05.042377 PM +00:00
	PCTTHRESHOLD  : 10
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	TABLE / (SUB)PARTITION STATISTICS DIFFERENCE:
	.............................................

	OBJECTNAME                  TYP SRC ROWS       BLOCKS     ROWLEN     SAMPSIZE
	...............................................................................

	FRA                         T   A   6          13         1788       6
									B   29999996   7659981    1793       29999996
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	COLUMN STATISTICS DIFFERENCE:
	.............................

	COLUMN_NAME     SRC NDV     DENSITY    HIST NULLS   LEN  MIN   MAX   SAMPSIZ
	...............................................................................

	ID              A   1.9E+07 .000000052 NO   0       9    31    39303 3.E+07
					B   7       .142857142 NO   0       5    31    31303 7
	LAST_MODIFIED   A   9262    .000107968 NO   0       11   78780 787C0 3.E+07
					B   7       .142857142 NO   0       11   78790 787C0 7
	SYS_IME_OSON_78 A   1       1          NO   0       2    EF    EF    3.E+07
					B   0       0          NO   7       0      0
	TIMESTAMPREQUES A   9262    .000107968 NO   0       11   78780 787C0 3.E+07
					B   7       .142857142 NO   0       11   78790 787C0 7
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	NO DIFFERENCE IN INDEX / (SUB)PARTITION STATISTICS
	###############################################################################
NB: durante il caricamento massivo, per lungo tempo, il numero di righe di FRA e' stato 7 (compare come NDV).  Ovvero al lancio di insert ... select...


select * from table (DBMS_STATS.DIFF_TABLE_STATS_IN_HISTORY (user,'FRA','28-AUG-24 10.11.05.042377 PM +00:00','28-AUG-24 01.47.26.076217 PM +00:00'));
--> 28ago chiusura lavori e le precedenti (quando l'indice non c'era)
	###############################################################################  99.9999767

	STATISTICS DIFFERENCE REPORT FOR:
	.................................

	TABLE         : FRA
	OWNER         : APPL1
	SOURCE A      : Statistics as of 28-AUG-24 10.11.05.042377 PM +00:00
	SOURCE B      : Statistics as of 28-AUG-24 01.47.26.076217 PM +00:00
	PCTTHRESHOLD  : 10
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	TABLE / (SUB)PARTITION STATISTICS DIFFERENCE:
	.............................................

	OBJECTNAME                  TYP SRC ROWS       BLOCKS     ROWLEN     SAMPSIZE
	...............................................................................

	FRA                         T   A   29999996   7659981    1793       29999996
									B   7          13         1786       7
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	COLUMN STATISTICS DIFFERENCE:
	.............................

	COLUMN_NAME     SRC NDV     DENSITY    HIST NULLS   LEN  MIN   MAX   SAMPSIZ
	...............................................................................

	ID              A   7       .142857142 NO   0       5    31    31303 7
					B   6       .166666666 NO   0       5    31    31303 6
	LAST_MODIFIED   A   7       .142857142 NO   0       11   78790 787C0 7
					B   6       .166666666 NO   0       11   78790 787C0 6
	SYS_IME_OSON_78 A   0       0          NO   7       0      0
					B   0       0          NO   6       0      0
	TIMESTAMPREQUES A   7       .142857142 NO   0       11   78790 787C0 7
					B   6       .166666666 NO   0       11   78790 787C0 6
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	NO DIFFERENCE IN INDEX / (SUB)PARTITION STATISTICS
	###############################################################################

select * from table (DBMS_STATS.DIFF_TABLE_STATS_IN_HISTORY (user,'FRA','28-AUG-24 01.47.26.076217 PM +00:00','28-AUG-24 09.57.33.766639 AM +00:00'));
-- prima dell'indice e appena dopo il caricamento:
	###############################################################################

	STATISTICS DIFFERENCE REPORT FOR:
	.................................

	TABLE         : FRA
	OWNER         : APPL1
	SOURCE A      : Statistics as of 28-AUG-24 01.47.26.076217 PM +00:00
	SOURCE B      : Statistics as of 28-AUG-24 09.57.33.766639 AM +00:00
	PCTTHRESHOLD  : 10
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	TABLE / (SUB)PARTITION STATISTICS DIFFERENCE:
	.............................................

	OBJECTNAME                  TYP SRC ROWS       BLOCKS     ROWLEN     SAMPSIZE
	...............................................................................

	FRA                         T   A   7          13         1786       7
									B   6          13         1788       6
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	COLUMN STATISTICS DIFFERENCE:
	.............................

	COLUMN_NAME     SRC NDV     DENSITY    HIST NULLS   LEN  MIN   MAX   SAMPSIZ
	...............................................................................

	ID              A   6       .166666666 NO   0       5    31    31303 6
					B   NO_STATS
	JSON_DOCUMENT   A   0       0          NO   0       1760   6
					B   NO_STATS
	LAST_MODIFIED   A   6       .166666666 NO   0       11   78790 787C0 6
					B   NO_STATS
	SYS_IME_OSON_78 A   0       0          NO   6       0      0
					B   NO_STATS
	TIMESTAMPREQUES A   6       .166666666 NO   0       11   78790 787C0 6
					B   NO_STATS
	VERSION         A   1       1          NO   0       2    31    31    6
					B   NO_STATS
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	NO DIFFERENCE IN INDEX / (SUB)PARTITION STATISTICS
	###############################################################################


quindi:
- le iniziali (vuote o poche righe) fino al mercoledì sera (28 agosto)
- il 28 a chiusura lavori, c'erano poche righe in FRA, e queste riproducono un buon piano
- le current sono NOStats e riproducono un buon piano

*/
set autotrace off
spool off

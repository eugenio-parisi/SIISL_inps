set lines 132 pages 999 time on timing on
spool test_recap_text_HCC_test23c

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
prompt test_recap, tutte le query da FRA_HCC (compressa HCC for query low)
alter system flush buffer_cache;
prompt query originale
SELECT * FROM FRA_HCC
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
SELECT * FROM FRA_HCC
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

prompt query senza clausola pleonastica e senza filtro su timestampRequestUtc
alter system flush buffer_cache;
SELECT * FROM FRA_HCC
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
-->veloce: questo probabilmente risolve il problema originato dal fatto che la forma HCC ha storage limitato.
set autotrace off
spool off

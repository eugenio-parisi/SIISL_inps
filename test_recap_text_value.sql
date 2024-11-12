set lines 132 pages 999 time on timing on
spool test_recap_text_value
-- crea l'indice
-- text_value e non text
alter index docinps_IDX1 noparallel;
DROP INDEX docinps_IDX1;
-- server taaaaanto temp tablespace...
CREATE INDEX docinps_IDX1 ON docinps (JSON_DOCUMENT) 
    INDEXTYPE IS CTXSYS.CONTEXT_V2 
    PARAMETERS ('SIMPLIFIED_JSON sync (every "freq=secondly; interval=1") search_on text_value  dataguide off') PARALLEL 6;
alter index docinps_IDX1 noparallel;
select count(1) from docinps;
select codice_fiscale from codice_fiscale where id=1000000;

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

alter system flush buffer_cache;

prompt query JSON solo TEXTCONTAINS, anche nota come s3
SELECT /*+ MONITOR GATHER_PLAN_STATISTICS */ * FROM "DOCINPS"
WHERE CONTAINS ("DOCINPS"."JSON_DOCUMENT" /*+ LOB_BY_VALUE */,'(DLRINZ28E53B362E)')>0;

alter system flush buffer_cache;

prompt vista più interna con JSON_VALUE, da test3 query 1
SELECT JSON_DOCUMENT         
FROM "DOCINPS" F 
WHERE JSON_EXISTS (F."JSON_DOCUMENT", '$.timestampRequestUtc') 
AND   JSON_TEXTCONTAINS (F."JSON_DOCUMENT", '$', 'THINTS00R45B455X') 
/

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

-- non cambia riscrivendola in vari modi

set autotrace off
spool off


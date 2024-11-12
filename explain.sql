set lines 132 pages 999
explain plan for
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
)
/
select * from table(dbms_xplan.display_cursor(format => 'allstats last'));


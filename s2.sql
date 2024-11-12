set lines 132 pages 999 time on timing on
set autot trace
SELECT /*+ MONITOR GATHER_PLAN_STATISTICS */ * FROM "Fra" 
WHERE JSON_TEXTCONTAINS(DATA, '$', 'XXXXXX72B14F839F')
/
set autot off


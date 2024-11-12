set lines 132 pages 999 time on timing on
set autot trace
SELECT /*+ MONITOR GATHER_PLAN_STATISTICS */ * FROM "Fra" 
WHERE CONTAINS ("Fra"."DATA" /*+ LOB_BY_VALUE */,'(XXXXXX72B14F839F)')>0
/
set autot off


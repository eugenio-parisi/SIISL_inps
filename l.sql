col message for a89
set lines 140
col stime for a19
col lupdtime for a8
col time_remaining hea togo for 999999
col sid for 9999
SELECT sid,to_char(start_time,'dd/mm/yyyy hh24:mi:ss') stime,
       message,time_remaining, to_char(last_update_time,'hh24:mi:ss') lupdtime
FROM v$session_longops
where time_remaining>0
--message like 'Gather Schema Statistics%'
order by 1
/

-- alternativa con ETA
col eta for a19
col message for a77
SELECT sid, -- to_char(start_time,'dd/mm/yyyy hh24:mi:ss') stime,time_remaining,
	to_char(sysdate+time_remaining/86400,'dd/mm/yyyy hh24:mi:ss') eta,message,time_remaining,
    to_char(last_update_time,'hh24:mi:ss') lupdtime
FROM v$session_longops
where time_remaining>0
--message like 'Gather Schema Statistics%'
order by 1
/

/*

select (100/PCT*ELA_SECS/86400)+sysdate from (
SELECT sum(sofar) sf, max(totalwork) tw, sum(sofar) / max(totalwork) *100 pct,
min(start_time) st,
(sysdate-min(start_time))*86400 ela_secs
FROM v$session_longops
where time_remaining>0
and MESSAGE like 'RMAN: full datafile restore%'
--message like 'Gather Schema Statistics%'
)
/
alter session set nls_date_format='dd-mm-yyyy hh24:mi:ss';

*/


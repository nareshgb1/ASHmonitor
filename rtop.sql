REM
REM  Author - Naresh Bhandare
REM  rtop.sql - show a pivot for activity for last 15 minutes from ASH (gv$active_session_history)
REM    several reports are shown
REM    - breakup by activity type - sql execution, parse, hard parse, connection management, BG process
REM    - breakup by Wait Class - CPU, Wait Class
REM    - breakup by event - either on CPU, or waiting for event
REM    - by SQL_ID
REM    - by module
REM
REM the report can help to identify source of bottleneck during performance issues
REM  ** Use at your own risk, no guaratantees implied ***
REM

clear breaks
set pages 2000 lines 166
set timing off feed off
column w format a32 heading "Process State"
col module for a29 trunc
column avrg format 9999.99 heading "Average|Count"
column t_1 format 999.9
column t_2 format 999.9
column t_3 format 999.9
column t_4 format 999.9
column t_5 format 999.9
column t_6 format 999.9
column t_7 format 999.9
column t_8 format 999.9
column t_9 format 999.9
column t_10 format 999.9
column t_11 format 999.9
column t_12 format 999.9
column t_13 format 999.9
column t_14 format 999.9
column t_15 format 999.9
col inst for 99

set head off
select 'Process States in previous 15 minutes - ' || db_unique_name || ' at ' || to_char(sysdate, 'mm/dd hh24:mi:ss') from v$database;
set head on

break on inst skip 1

select * from (
	select inst, w 
		,round(sum(cnt)/15,2)                        avrg
		,round(sum(decode(mins_hist, 1,cnt,null)),2) t_1
		,round(sum(decode(mins_hist, 2,cnt,null)),2) t_2
		,round(sum(decode(mins_hist, 3,cnt,null)),2) t_3
		,round(sum(decode(mins_hist, 4,cnt,null)),2) t_4
		,round(sum(decode(mins_hist, 5,cnt,null)),2) t_5
		,round(sum(decode(mins_hist, 6,cnt,null)),2) t_6
		,round(sum(decode(mins_hist, 7,cnt,null)),2) t_7
		,round(sum(decode(mins_hist, 8,cnt,null)),2) t_8
		,round(sum(decode(mins_hist, 9,cnt,null)),2) t_9
		,round(sum(decode(mins_hist,10,cnt,null)),2) t_10
		,round(sum(decode(mins_hist,11,cnt,null)),2) t_11
		,round(sum(decode(mins_hist,12,cnt,null)),2) t_12
		,round(sum(decode(mins_hist,13,cnt,null)),2) t_13
		,round(sum(decode(mins_hist,14,cnt,null)),2) t_14
		,round(sum(decode(mins_hist,15,cnt,null)),2) t_15
	from (
		select  inst, mins_hist, w, count(*) / 60 cnt
		from
			(select inst_id inst, sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				case 
					when in_hard_parse = 'Y' then 'hard parse'
					when in_parse = 'Y' then 'parse'
				     when in_connection_mgmt = 'Y' then 'conn mgmt'
					when IN_SQL_EXECUTION = 'Y' then 'sql exec'
					when IN_PLSQL_EXECUTION = 'Y' then 'plsql exec'
					when IN_SEQUENCE_LOAD = 'Y' then 'seq Load'
					when SESSION_TYPE = 'BACKGROUND' then 'BG process'
				end as w
				--decode(in_hard_parse, 'CPU', 'CPU', event) w
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by inst, mins_hist, w
		)
	group by inst, w
	order by nvl(avrg,0) desc
	)
where  avrg > 0
  and rownum <= 25
order by inst, avrg desc
/

select * from (
	select inst, w 
		,round(sum(cnt)/15,2)                        avrg
		,round(sum(decode(mins_hist, 1,cnt,null)),2) t_1
		,round(sum(decode(mins_hist, 2,cnt,null)),2) t_2
		,round(sum(decode(mins_hist, 3,cnt,null)),2) t_3
		,round(sum(decode(mins_hist, 4,cnt,null)),2) t_4
		,round(sum(decode(mins_hist, 5,cnt,null)),2) t_5
		,round(sum(decode(mins_hist, 6,cnt,null)),2) t_6
		,round(sum(decode(mins_hist, 7,cnt,null)),2) t_7
		,round(sum(decode(mins_hist, 8,cnt,null)),2) t_8
		,round(sum(decode(mins_hist, 9,cnt,null)),2) t_9
		,round(sum(decode(mins_hist,10,cnt,null)),2) t_10
		,round(sum(decode(mins_hist,11,cnt,null)),2) t_11
		,round(sum(decode(mins_hist,12,cnt,null)),2) t_12
		,round(sum(decode(mins_hist,13,cnt,null)),2) t_13
		,round(sum(decode(mins_hist,14,cnt,null)),2) t_14
		,round(sum(decode(mins_hist,15,cnt,null)),2) t_15
	from (
		select  inst, mins_hist, w, count(*) / 60 cnt
		from
			(select inst_id inst, sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				decode(session_state, 'ON CPU', 'CPU', wait_class) w
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by inst, mins_hist, w
		)
	group by inst, w
	order by nvl(avrg,0) desc
	)
where  avrg > 0
  and rownum <= 25
order by inst, avrg desc
/


select * from (
	select inst, w 
		,round(sum(cnt)/15,2)                        avrg
		,round(sum(decode(mins_hist, 1,cnt,null)),2) t_1
		,round(sum(decode(mins_hist, 2,cnt,null)),2) t_2
		,round(sum(decode(mins_hist, 3,cnt,null)),2) t_3
		,round(sum(decode(mins_hist, 4,cnt,null)),2) t_4
		,round(sum(decode(mins_hist, 5,cnt,null)),2) t_5
		,round(sum(decode(mins_hist, 6,cnt,null)),2) t_6
		,round(sum(decode(mins_hist, 7,cnt,null)),2) t_7
		,round(sum(decode(mins_hist, 8,cnt,null)),2) t_8
		,round(sum(decode(mins_hist, 9,cnt,null)),2) t_9
		,round(sum(decode(mins_hist,10,cnt,null)),2) t_10
		,round(sum(decode(mins_hist,11,cnt,null)),2) t_11
		,round(sum(decode(mins_hist,12,cnt,null)),2) t_12
		,round(sum(decode(mins_hist,13,cnt,null)),2) t_13
		,round(sum(decode(mins_hist,14,cnt,null)),2) t_14
		,round(sum(decode(mins_hist,15,cnt,null)),2) t_15
	from (
		select  inst, mins_hist, w, count(*) / 60 cnt
		from
			(select inst_id inst, sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				decode(session_state, 'ON CPU', 'CPU', event) w
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by inst, mins_hist, w
		)
	group by inst, w
	order by nvl(avrg,0) desc
	)
where  avrg > 0
  and rownum <= 25
order by inst, avrg desc
/

select * from (
select * from (
	select inst, sql_id
		,round(sum(cnt)/15,2)                        avrg
		,round(sum(decode(mins_hist, 1,cnt,null)),2) t_1
		,round(sum(decode(mins_hist, 2,cnt,null)),2) t_2
		,round(sum(decode(mins_hist, 3,cnt,null)),2) t_3
		,round(sum(decode(mins_hist, 4,cnt,null)),2) t_4
		,round(sum(decode(mins_hist, 5,cnt,null)),2) t_5
		,round(sum(decode(mins_hist, 6,cnt,null)),2) t_6
		,round(sum(decode(mins_hist, 7,cnt,null)),2) t_7
		,round(sum(decode(mins_hist, 8,cnt,null)),2) t_8
		,round(sum(decode(mins_hist, 9,cnt,null)),2) t_9
		,round(sum(decode(mins_hist,10,cnt,null)),2) t_10
		,round(sum(decode(mins_hist,11,cnt,null)),2) t_11
		,round(sum(decode(mins_hist,12,cnt,null)),2) t_12
		,round(sum(decode(mins_hist,13,cnt,null)),2) t_13
		,round(sum(decode(mins_hist,14,cnt,null)),2) t_14
		,round(sum(decode(mins_hist,15,cnt,null)),2) t_15
	from (
		select  inst, mins_hist, sql_id, count(*) / 60 cnt
		from
			(select inst_id inst, sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				sql_id
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by inst, mins_hist, sql_id
		)
	group by inst, sql_id
	order by nvl(avrg,0) desc
	)
where  avrg > 0
  and rownum <= 25
order by avrg desc
) order by inst, avrg desc
/

select * from (
select * from (
	select inst, module
		,round(sum(cnt)/15,2)                        avrg
		,round(sum(decode(mins_hist, 1,cnt,null)),2) t_1
		,round(sum(decode(mins_hist, 2,cnt,null)),2) t_2
		,round(sum(decode(mins_hist, 3,cnt,null)),2) t_3
		,round(sum(decode(mins_hist, 4,cnt,null)),2) t_4
		,round(sum(decode(mins_hist, 5,cnt,null)),2) t_5
		,round(sum(decode(mins_hist, 6,cnt,null)),2) t_6
		,round(sum(decode(mins_hist, 7,cnt,null)),2) t_7
		,round(sum(decode(mins_hist, 8,cnt,null)),2) t_8
		,round(sum(decode(mins_hist, 9,cnt,null)),2) t_9
		,round(sum(decode(mins_hist,10,cnt,null)),2) t_10
		,round(sum(decode(mins_hist,11,cnt,null)),2) t_11
		,round(sum(decode(mins_hist,12,cnt,null)),2) t_12
		,round(sum(decode(mins_hist,13,cnt,null)),2) t_13
		,round(sum(decode(mins_hist,14,cnt,null)),2) t_14
		,round(sum(decode(mins_hist,15,cnt,null)),2) t_15
	from (
		select  inst, mins_hist, module, count(*) / 60 cnt
		from
			(select inst_id inst, sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				nvl(module, program) as module
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by inst, mins_hist, module
		)
	group by inst, module
	order by nvl(avrg,0) desc
	)
where  avrg > 0
  and rownum <= 25
)
order by inst, avrg desc
/


REM  This is based on the rtop.sql and generates similar info for ASH activity filtered for a wait event
REM  Usage, e.g. at sqlplus prompt
REM  > @rte
REM  enter event or CPU [use %] : cell single block physical re%
REM
REM  this will show pivot for activity per minute for this event in terms of sql_id and module
REM  any spikes and anomalies seen can be used to drill down to identify issues

set pages 2000 lines 166 verify off
set timing off feed off
column w format a29 heading "Process State"
column avrg format 9999.9 heading "Average|Count"
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
col module for a35 trunc
col inst for 99
break on inst


accept evt prompt "enter event or CPU [use %] : "

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
                          and decode(session_state, 'ON CPU', 'CPU', event) like '&evt'
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


prompt
prompt modules for event &evt
prompt

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
				nvl(module, program) module
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  and decode(session_state, 'ON CPU', 'CPU', event) like '&evt'
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by inst, mins_hist, module
		)
	group by inst, module
	order by nvl(avrg,0) desc
	)
where  rownum <= 25
) order by inst, avrg desc
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
			  and decode(session_state, 'ON CPU', 'CPU', event) like '&evt'
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by inst, mins_hist, sql_id
		)
	group by inst, sql_id
	order by nvl(avrg,0) desc
	)
where  rownum <= 25
) order by inst, avrg desc
/

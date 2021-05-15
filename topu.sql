REM Author: Naresh Bhandare
REM - use at yoru own risk, no guarantees implied
REM
REM just a variation on rtop.sql - it shows activity by gv$session.username
REM   shows pivot of activity per minute for last 15 minutes 
REM    by username, useful at times to drill down when multiples schemas are runnign same sqls


clear breaks
set pages 2000 lines 166
set timing off feed off
column w format a29 heading "Process State"
col module for a29 trunc
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

prompt Process States in last 15 minutes

select * from (
	select username
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
		select  mins_hist, user_id, count(*) / 60 cnt
		from
			(select sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				user_id
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by mins_hist, user_id
		)v, dba_users u
	where v.user_id = u.user_id
	group by username
	order by nvl(avrg,0) desc
	)
where  avrg > 0
  and rownum <= 25
/

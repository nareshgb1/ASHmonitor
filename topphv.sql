REM Author Naresh Bhandare
REM (use at your own ris - no gurantees implied)
REM
REM another varation on rtop.sql, this one shows activity breakup by sql plan_hash_value
REM  this is useful when literal sqls are used and individual sqls will nto appear in the rtop.sql
REM


clear breaks
set pages 2000 lines 166
set timing off feed off
column w format a29 heading "Process State"
col module for a29 trunc
column avrg format 9999.9 heading "Average|Count"
col sql_ct for 999
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
	select sql_plan_hash_value phv
		, sql_ct, module
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
		select  mins_hist, sql_plan_hash_value, module, count(*) / 60 cnt, count(distinct sql_id) sql_ct
		from
			(select sysdate sdt, 
                                trunc(( sysdate - to_date(to_char(sample_time,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')) * 24  * 60) mins_hist,
				--trunc((sysdate - sample_time) * 24  * 60) mins_hist, 
				sql_plan_hash_value, sql_id, module
			from gv$active_session_history a
			where sample_time >= sysdate - 0.25/24
			  --and sample_time <= to_date(to_char(sysdate,'YYYYMMDDHH24MI'),'YYYYMMDDHH24MI')
			) a
		group by mins_hist, sql_plan_hash_value, module
		)
	group by sql_plan_hash_value, sql_ct, module
	order by nvl(avrg,0) desc
	)
where  avrg > 0
  and rownum <= 25
/

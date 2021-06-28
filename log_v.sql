create or replace view log_v as
select
   round(tim.s_ago(log.tm), 1) as s_ago,
   log.msg                 ,
   log.call                ,
   log.lin                 ,
   log.exc                 ,
   tsk.name  task_name     ,
   log.tm                  ,
   tsk.start_s_ago task_exec_start_s_ago    ,
   tsk.end_s_ago   task_exec_end_s_ago    ,
-- tsk.ts    task_ts       ,
   tsk.usr                 ,
   tsk.usr_proxy           ,
   tsk.usr_os              ,
   tsk.sid                 ,
   tsk.serial#             ,
   log.id                  ,
   tsk.task_id             ,
   tsk.id   task_exec_id   ,
   tsk.ses_id              ,
   case when tsk.ses_id = ses_mgmt.id       then 'y' else 'n' end cur_ses,
   tsk.cur_ses_r,
   tsk.cur_task
from
   log                                      join
   task_exec_v  tsk on log.task_exec_id = tsk.id
;

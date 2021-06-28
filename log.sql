create table log (
   tm           timestamp       default systimestamp not null,
   msg          clob,
   call         varchar2(4000),
   lin          number(6),
   exc          varchar2(1)     check (exc in ('!')),
   task_exec_id integer         not null,
   id           integer         generated always as identity,
   --
   constraint log_pk            primary key (id     ),
   constraint log_fk_task_exec  foreign key (task_exec_id) references task_exec
);

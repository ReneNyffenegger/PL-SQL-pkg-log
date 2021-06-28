create table call_stack_entry (
   owner         varchar2(128)       null,
   package       varchar2(128)       null,
   subprogram    varchar2(128)       null,
   line          integer             null,
   flg           varchar2(  1)       null,
   depth         integer         not null,
   call_stack_id integer         not null,
   id            integer         generated always as identity,
   --
   constraint call_stack_entry_pk primary key (id),
   constraint call_stack_emtru_fk foreign key (call_stack_id) references call_stack
);

create table error_stack_entry (
   nr              integer         not null,
   msg             varchar2(500)   not null,
   --
   error_stack_id  integer         not null,
   id              integer         generated always as identity,
   --
   constraint error_stack_entry_pk primary key (id),
   constraint error_stack_entry_fk foreign key (error_stack_id) references error_stack
);

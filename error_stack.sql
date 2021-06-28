create table error_stack (
   ts             timestamp,
   id             integer         generated always as identity,
   --
   constraint error_stack_pk primary key (id)
);

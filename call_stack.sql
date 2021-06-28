create table call_stack (
   ts           timestamp,
   id           integer         generated always as identity,
   --
   constraint call_stack_pk primary key (id)
);

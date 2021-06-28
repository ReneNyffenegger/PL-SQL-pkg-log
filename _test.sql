declare
   id integer;
begin
   id := log_mgmt.dump_call_stack;
end;
/


create or replace package tq84_log_test_a as
     procedure p_1(val integer);
end tq84_log_test_a;
/

create or replace package tq84_log_test_b as
     procedure wrap_log_entry(val integer);
     procedure p_2           (txt varchar2);
end tq84_log_test_b;
/

create or replace package body tq84_log_test_a as

    procedure throw_exception is
    begin
        raise_application_error(-20800, 'exc!');
    end throw_exception;

    procedure p_1(val integer) is

       id integer;
       procedure p_1_nested(val integer) is
       begin
           log_mgmt.msg('val = ' || val);
           tq84_log_test_b.p_2('* ' || val || ' *');
       end p_1_nested;

    begin
       log_mgmt.msg('val = ' || val);
       p_1_nested(val * 2);
       tq84_log_test_b.wrap_log_entry(val);

       throw_exception;
    exception when others then
       id := log_mgmt.dump_call_stack;
       raise;
    end p_1;

end tq84_log_test_a;
/


create or replace package body tq84_log_test_b as

    procedure wrap_log_entry(val integer) is
    begin
       log_mgmt.msg('wrap_log got val at ' || sysdate, skip_stack_levels => 1);
    end wrap_log_entry;

    procedure p_2(txt varchar2) is
    begin
       log_mgmt.msg('txt = ' || txt);
    end p_2;

end tq84_log_test_b;
/





declare
   id integer;

   procedure anon_b is begin
       id := log_mgmt.dump_call_stack;
   end anon_b;

   procedure anon_a is
       procedure anon_a_a is begin
          id := log_mgmt.dump_call_stack;
          anon_b;
       end anon_a_a;
   begin
       anon_a_a;
   end anon_a;

begin
   task_mgmt.begin_('test log');
   anon_a;
   tq84_log_test_a.p_1(12);
   task_mgmt.done;
exception when others then
   task_mgmt.exc;
end;
/


create or replace procedure test_proc_for_exc as   --  1
                                                   --  2
   procedure A(i number) is begin                  --  3
      if i = 0 then                                --  4
         raise_application_error(-20800, 'exc');   --  5  !
      end if;                                      --  6
   end A;                                          --  7
                                                   --  8
   procedure B is begin                            --  9
      A( 2);                                       -- 10
      A( 1);                                       -- 11
      A( 0);                                       -- 12  !
      A(-1);                                       -- 13
   end B;                                          -- 14
                                                   -- 15
   procedure C is begin                            -- 16
      B;                                           -- 17  !
   end C;                                          -- 18
begin                                              -- 19
   C;                                              -- 20  !
exception when others then                         -- 21
   dbms_output.put_line(                           -- 22  *
     'cs: ' || log_mgmt.dump_call_stack            -- 23
   );                                              -- 24
   dbms_output.put_line(                           -- 25
     'es: ' || log_mgmt.dump_error_stack           -- 26
   );                                              -- 27
end;                                               -- 28
/

exec null;
exec test_proc_for_exc;

select * from error_stack_entry where error_stack_id = 1;

select * from call_stack;
select * from call_stack_line where call_stack_id = 20 order by depth;

select * from log_v order by id desc;s
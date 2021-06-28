create or replace package body log_mgmt as
 --
 -- V0.1
 --
    procedure msg(
       msg                clob,
       skip_stack_levels  integer := 0
    ) as -- {
       pragma autonomous_transaction;
       call varchar2(4000);
       lin  number;
       stack_levels integer := 2 + skip_stack_levels;
    begin

       call := utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram( stack_levels ));
       lin  := utl_call_stack.unit_line                                       ( stack_levels ) ;

       insert into log (
          msg,
          call,
          lin,
          task_exec_id
       )
        values (
          msg,
          call,
          lin,
          task_mgmt.cur_task
       );

       commit;

    end msg; -- }

    procedure exc( -- {
        msg     clob    := null,
        reraise boolean := true
    )
    as
       pragma autonomous_transaction;
       call varchar2(4000);
       lin  number;

       cs   integer;
       es   integer;

       sqlerrm_ varchar2(500) := sqlerrm;

    begin

       call := utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram( 2 ));
       lin  := utl_call_stack.unit_line                                       ( 2 ) ;

       cs   := dump_call_stack(skip_stack_levels => 0);
       es   := dump_error_stack;

       insert into log (
          msg,
          call,
          lin,
          exc,
          task_exec_id
       )
        values (
--       'error_depth: ' || utl_call_stack.error_depth || ', ' ||
          case when msg is not null then msg || chr(10) end ||
         'Call stack: ' || cs || ', error stack: ' || es || chr(10) ||
          sqlerrm_ || chr(10) ||
          dbms_utility.format_error_backtrace,
          call,
          lin,
         '!',
          task_mgmt.cur_task
       );

       commit;

       if reraise then
          raise_application_error(-20800, case when msg is not null then msg else sqlerrm_ end);
       end if;

    end exc; -- }

    function dump_error_stack return integer is -- {
       pragma autonomous_transaction;
       id_ integer;
    begin

       insert into error_stack(ts) values (systimestamp) returning id into id_;
       for d in 1 .. utl_call_stack.error_depth loop

           insert into error_stack_entry(nr, msg, error_stack_id) values (
              utl_call_stack.error_number(d),
              utl_call_stack.error_msg   (d),
              id_
           );

       end loop;

       commit;

       return id_;

    end dump_error_stack; -- }

    function dump_call_stack(skip_stack_levels integer := 0)  return integer is -- {
       pragma autonomous_transaction;

       stack_levels integer := 2 + skip_stack_levels;

       id_ integer;

       dn  integer;
       qn  utl_call_stack.unit_qualified_name;
       pkg varchar2(128);
       ow  varchar2(128);
       sp  varchar2(128);
       ul  integer;


       ed  integer;
       bd  integer;
       i   integer;

       btu varchar2(128);
    begin

       insert into call_stack(ts) values (systimestamp) returning id into id_;

       dn := utl_call_stack.dynamic_depth;
       for d in stack_levels .. dn loop

           ow := utl_call_stack.owner(d);
           qn := utl_call_stack.subprogram(d);
           sp := qn(qn.count);
           ul := utl_call_stack.unit_line(d);

           insert into call_stack_entry (owner, package, subprogram, line, flg, depth, call_stack_id)
           values (
               ow,
               qn(1),
               sp,
               ul,
               case when d = stack_levels then '*' end,
               dn - d,
               id_
           );

       end loop;

       ed := utl_call_stack.error_depth;
       bd := utl_call_stack.backtrace_depth;

       for d in 1 .. bd loop
           btu := utl_call_stack.backtrace_unit(d);
           i   := instr(btu, '.');
           ow  := substr(btu, 1, i-1);
           pkg := substr(btu, i+1);
           ul  := utl_call_stack.backtrace_line(d);

           insert into call_stack_entry (owner, package, subprogram, line, flg, depth, call_stack_id)
           values (
               ow,
               pkg,
               null,
               ul,
              '!',
               bd - d + stack_levels,
               id_
           );

       end loop;
       commit;

       return id_;

    end dump_call_stack; -- }

end log_mgmt;
/

show errors

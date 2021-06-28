create or replace package log_mgmt as
 --
 -- V0.1
 --

    procedure msg(msg               clob,
                  skip_stack_levels integer := 0);

    procedure exc(
                  msg    clob      := null,
                  reraise boolean  := true
                 );

    function dump_error_stack
    return   integer;

    function dump_call_stack(skip_stack_levels integer := 0)
    return integer;

end log_mgmt;
/

show errors

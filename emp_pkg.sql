
--package spec
create or replace package emp_package                --package creation without parameter
as
procedure emp_pro(p_empno in number);                --procedure declaration with parameter
function emp_fun(p_empno number)return number;       --function declaration with parameter
end emp_package;
/

--package body
create or replace package body emp_package            --started package body creation
as
procedure emp_pro(p_empno in number)                  --started creating emp_pro procedure
is
 v_ename varchar2(10);                                --declaring variables
 v_sal number;
 v_comm number;
begin
 select ename,sal,comm into v_ename,v_sal,v_comm from emp where empno=p_empno;   --assigning data into variables
 dbms_output.put_line(v_ename||','||v_sal||','||v_comm);
exception 
  when others then
dbms_output.put_line('NO DATA FOUND');                              --exception handling
end emp_pro;                                              --completed emp_pro procedure

function emp_fun(p_empno in number)return number         --started creating function emp_fun for return gross_sal
as
  v_basic_sal number(10);                                 --variable declaration
  v_gross_sal number(10);
  v_hra number(10);
  v_da number(10);
  v_pf number(10);
begin
 select sal into v_basic_sal from emp where empno=p_empno;   --assigning data into variables
  v_hra:=v_basic_sal*0.1;                                    --condition
  v_da:=v_basic_sal*0.2;
  v_pf:=v_basic_sal*0.3;
  v_gross_sal:=v_basic_sal+v_hra+v_da+v_pf;
return v_gross_sal;                                           --return gross_sal
exception                                                     --exception handling with pre-defined type
 when others then
dbms_output.put_line('NO DATA FOUND');

end emp_fun;                                                  --completed emp_fun function

end emp_package;                                              --end package
/

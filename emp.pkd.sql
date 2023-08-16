
--package spec
CREATE OR REPLACE PACKAGE EMPLOYEE_DETAILS_PACK_1 AS 
   PROCEDURE main(p_EMPNO in number);   --package main creation by passing parameter empno

END EMPLOYEE_DETAILS_PACK_1; 
/



--package BODY

  CREATE OR REPLACE PACKAGE BODY employee_details_PACK_1 AS  

  F UTL_FILE.FILE_TYPE;                         --variable declaration

  PROCEDURE load_employee_details(p_empno in number)     --procedure creation for loading data 
  IS
  BEGIN
  F := UTL_FILE.FOPEN('EMP_LOG','emp_details_1.LOG','A');    --log file creation (directory path,file_name,mode)

        UTL_FILE.PUT(F,'------------------------------------------------------'||chr(10));
       
        UTL_FILE.PUT(F,'1:-'||CHR(10));                 
        UTL_FILE.PUT(F,'------------------------------------------------------'||chr(10));

	    UTL_FILE.PUT(F,'started the process for:- ' ||p_empno||chr(10));     --started process for empno
	    
	    dbms_output.put_line('started truncating emp_dept_stage_table');
	    
	    UTL_FILE.PUT(F,'started truncating table emp_dept_stage_table'||chr(10));

	    EXECUTE IMMEDIATE 'truncate table emp_dept_stage_table';             --truncating table for avoiding duplicates
	    
	    UTL_FILE.PUT(F,'completed truncating table emp_dept_stage_table'||chr(10));

	    
	    dbms_output.put_line('completed truncating emp_deptstage_table');
		
        INSERT INTO EMP_DEPT_STAGE_TABLE                                      --loading data into stage table
       (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO,
		DNAME,
		LOC
        )
       SELECT                  
       E.EMPNO,                --select rows from emp table
       E.ENAME,
       E.JOB,
       E.MGR,
       E.HIREDATE,
       E.SAL,
       E.COMM,
       E.DEPTNO,
       D.DNAME,                --rows from dept table
       D.LOC FROM EMP E JOIN DEPT D   --joining emp table and dept table
	   ON E.DEPTNO=D.DEPTNO;
	   UTL_FILE.PUT(F,SQL%ROWCOUNT || ' rows added in the table <emp_dept_stage_table>.'||chr(10));  --counting no of rows reflected
		
        commit; 
	    UTL_FILE.PUT(F,'------------------------------------------------------'||chr(10));

        UTL_FILE.FCLOSE(F);

		
  END load_employee_details;    --end procedure load_employee_details
  
  PROCEDURE export_to_csv        --procedure creation for ouput file
  IS
        v_file     UTL_FILE.file_type;   --variable declaration
        v_string   VARCHAR2 (4000);      --variable declaration

        CURSOR C_EMP                     -- cursor declaration
        IS
      
       SELECT 
       E.EMPNO,                   --selecting rows from emp table
       E.ENAME,
       E.Job,
       E.MGR,
       E.HIREDATE,
       E.SAL,
       E.COMM,
       SUM(E.SAL+E.COMM) AS SUM_SAL,   --totalsalary
       E.SAL*0.1 AS HRA,               --hra calculation
       E.SAL*0.2 AS DA,                --da calculation
       E.SAL*0.3 AS PF,                --pf calculation
       E.DEPTNO,
       D.DNAME,
       D.LOC FROM EMP E JOIN DEPT D    --joining emp and dept tables
	   ON E.DEPTNO=D.DEPTNO GROUP BY E.EMPNO, E.ENAME, E.Job, E.MGR, E.HIREDATE, E.SAL, E.COMM, E.SAL*0.1, E.DEPTNO, D.DNAME, D.LOC ORDER BY DEPTNO;

      BEGIN
       F := UTL_FILE.FOPEN('EMP_LOG','emp_details_1.LOG','A');       
       
        UTL_FILE.PUT(F,'2:-'||CHR(10));                 
        UTL_FILE.PUT(F,'------------------------------------------------------'||chr(10));

        UTL_FILE.PUT(F,'started generating output fiLE:- ' ||chr(10));              

        v_file := UTL_FILE.fopen('EMP_OUTPUT','employee.csv','w',32000);               -- started generating output file(directory path,file location,mode,LENGTH)
        v_string := 'empno,ename,job,mgr,hiredate,sal,comm,deptno,dname,loc,sum_sal,hra,da,pf'; --assighning values into variable
   
       UTL_FILE.put_line (v_file, v_string);                        -- writing headers
   
      FOR cur IN C_EMP                    --writing data to varibale from cursor by for loop
      LOOP
      v_string := cur.empno||','||cur.ename||','||cur.job||','||CUR.mgr||','||CUR.hiredate||','||CUR.sal||','||CUR.comm||','||CUR.deptno||','||cur.dname||','||cur.loc||','||cur.sum_sal||','||cur.hra||','||cur.da||','||cur.pf;
       
      UTL_FILE.put_line (v_file, v_string);    --writing data to csv file from variable

      END LOOP;                          -- ending loop
      UTL_FILE.fclose (v_file);           --completed generating output file
      UTL_FILE.PUT(F,'completed generating output fiLE:- ' ||chr(10));
      UTL_FILE.fclose (F);


     EXCEPTION                     --exception handling
     WHEN OTHERS
     THEN
      IF UTL_FILE.is_open (v_file)
      THEN
         UTL_FILE.fclose (v_file);
      END IF;
      
END export_to_csv;

   PROCEDURE main(p_empno in number)     --main procedure started
   is
   begin
   F := UTL_FILE.FOPEN('EMP_LOG','emp_details_1.LOG','A');    

        UTL_FILE.PUT(F,'------------------------------------------------------'||chr(10));
       
        UTL_FILE.PUT(F,'0:-'||TO_CHAR(SYSDATE,'DD-MM-YYYY HH12:MI:SS')||CHR(10));   
                    
        UTL_FILE.PUT(F,'------------------------------------------------------'||chr(10));

        UTL_FILE.PUT(F,'completed loading process for:- '||p_empno||chr(10));
        UTL_FILE.FCLOSE(F);  
        load_employee_details(p_empno);  
        export_to_csv;


   end main;

END EMPLOYEE_DETAILS_PACK_1;
/
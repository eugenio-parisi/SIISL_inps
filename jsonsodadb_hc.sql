REM srdc_JSONDB_Health_Check.sql - collect Oracle JSON Database Health Check information
define SRDCNAME='JSON_SODA_DB_Health_Check'
SET MARKUP HTML ON PREFORMAT ON
set TERMOUT off FEEDBACK off VERIFY off TRIMSPOOL on HEADING off
COLUMN SRDCSPOOLNAME NOPRINT NEW_VALUE SRDCSPOOLNAME
select 'SRDC_'||upper('&&SRDCNAME')||'_'||upper(instance_name)||'_'||
        to_char(sysdate,'YYYYMMDD_HH24MISS') SRDCSPOOLNAME from v$instance;
set TERMOUT on MARKUP html preformat on
REM
spool &&SRDCSPOOLNAME..txt
select '+----------------------------------------------------+' from dual
union all
select '| Diagnostic-Name: '||'&&SRDCNAME' from dual
union all
select '| Timestamp:       '||
        to_char(systimestamp,'YYYY-MM-DD HH24:MI:SS TZH:TZM') from dual
union all
select '| Machine:         '||host_name from v$instance
union all
select '| Version:         '||version from v$instance
union all
select '| DBName:          '||name from v$database
union all
select '| Instance:        '||instance_name from v$instance
union all
select '+----------------------------------------------------+' from dual
/
set HEADING on MARKUP html OFF preformat off
REM === -- end of standard header -- ===
REM
SET LINESIZE 80;
SET SERVEROUTPUT ON FORMAT WRAP;
DECLARE
 db_name     VARCHAR2(30);
 db_version  VARCHAR2(30);
 v_count     NUMBER := 0;
 ctx_check   NUMBER := 0;
 v_ver_dict  VARCHAR2(10);
 v_ver_code  VARCHAR2(10);
 v_dri_ver   VARCHAR2(10);
 v_stmt VARCHAR2 (2000);
 jsontextcont_except EXCEPTION;
 PRAGMA EXCEPTION_INIT(jsontextcont_except, -40467);
 v_json_check_c NUMBER;
 v_json_text_indexes_c NUMBER;

 CURSOR c_feat IS SELECT comp_name,status,version
   FROM dba_registry ORDER BY comp_id;
 CURSOR c_json_inval IS SELECT * FROM dba_objects
   WHERE status !='VALID' AND OWNER = 'SYS' AND OBJECT_NAME LIKE '%JSON%' ORDER BY object_type, object_name;
 CURSOR c_soda_inval IS SELECT * FROM dba_objects
   WHERE status !='VALID' AND OWNER = 'XDB' AND OBJECT_NAME LIKE '%SODA%' ORDER BY object_type, object_name;
 CURSOR c_xdb_inval IS SELECT * FROM dba_objects
   WHERE status !='VALID' AND OWNER = 'XDB' ORDER BY object_type, object_name; 
 CURSOR c_other_objects IS SELECT owner, object_name, object_type, status FROM dba_objects
   WHERE owner = 'SYS'
     AND (object_name like 'CTX_%' or object_name like 'DRI%')
   ORDER BY 2,3;
 CURSOR c_count_obj IS SELECT object_type, count(*) count FROM dba_objects
   WHERE owner='CTXSYS' GROUP BY object_type ORDER BY 1;
 CURSOR c_xdb_count IS SELECT object_type, count(*) count FROM dba_objects WHERE owner='XDB' GROUP BY object_type ORDER BY 1;
 CURSOR c_json_count IS SELECT object_type, count(*) count FROM dba_objects WHERE owner='SYS' and object_name like '%JSON%' GROUP BY object_type ORDER BY 1;
 CURSOR c_soda_count IS SELECT object_type, count(*) count FROM dba_objects WHERE owner='XDB' and object_name like '%SODA%' GROUP BY object_type ORDER BY 1; 
 CURSOR c_text_indexes IS
   SELECT c.*, i.status,i.domidx_status,i.domidx_opstatus
   FROM ctxsys.ctx_indexes c, dba_indexes i
   WHERE c.idx_owner = i.owner
     AND c.idx_name = i.index_name
   ORDER BY 2,3;
 CURSOR c_json_check IS SELECT * FROM dba_json_columns
   ORDER BY owner, table_name;

 CURSOR c_json_text_indexes IS
  select ci.*, i.*, sg.*, tc.data_type
from ctxsys.ctx_indexes ci, ctxsys.dr$class c, ctxsys.dr$object o, ctxsys.dr$index_object io, sys.dba_users u, ctxsys.dr$section_group sg, dba_indexes i,dba_tab_columns tc
where sg.sgp_name = 'JSON_SECTION_GROUP'
  and tc.table_name = ci.idx_table 
  and tc.column_name = ci.idx_text_name  
  and sg.sgp_obj_id = o.obj_id
  and io.ixo_cla_id = c.cla_id
  and io.ixo_cla_id = o.obj_cla_id
  and io.ixo_obj_id = o.obj_id
  and io.ixo_idx_id = ci.idx_id
  and ci.idx_owner = i.owner
  and ci.idx_name = i.index_name
  and ci.idx_owner = u.username; 
 CURSOR c_json_dba_errors IS SELECT owner, name, type, line, position, text
  FROM dba_errors
  WHERE owner IN ('SYS', 'XDB')
   and name  LIKE '%JSON%'
  ORDER BY owner, name, sequence;
 CURSOR c_soda_dba_errors IS SELECT owner, name, type, line, position, text
  FROM dba_errors
  WHERE owner IN ('SYS', 'XDB')
   and name  LIKE '%SODA%'
  ORDER BY owner, name, sequence;
 CURSOR c_xdb_dba_errors IS SELECT owner, name, type, line, position, text
  FROM dba_errors
  WHERE owner = 'XDB'
  ORDER BY owner, name, sequence;
 CURSOR c_json_text_err is
  select u.*, ie.*, i.*
from ctxsys.dr$index i, ctxsys.dr$class c, ctxsys.dr$object o, ctxsys.dr$index_object io, sys.user$ u, ctxsys.dr$section_group sg, ctxsys.dr$index_error ie
where sg.sgp_name = 'JSON_SECTION_GROUP'
  and sg.sgp_obj_id = o.obj_id
  and io.ixo_cla_id = c.cla_id
  and io.ixo_cla_id = o.obj_cla_id
  and io.ixo_obj_id = o.obj_id
  and io.ixo_idx_id = i.idx_id
  and i.idx_id = ie.err_idx_id
  and idx_owner# = u.user#
  order by ie.err_timestamp DESC, u.name, i.idx_name;

 PROCEDURE display_banner
 IS
 BEGIN
   DBMS_OUTPUT.PUT_LINE( '**********************************************************************');
 END display_banner;

BEGIN
 DBMS_OUTPUT.ENABLE(900000);
 SELECT name INTO db_name FROM v$database;
 SELECT version INTO db_version FROM v$instance;

 DBMS_OUTPUT.PUT_LINE( 'JSON and SODA Database Health Check Tool ' || TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
 DBMS_OUTPUT.PUT_LINE('.');
 display_banner;
 DBMS_OUTPUT.PUT_LINE('Database:');
 display_banner;
 DBMS_OUTPUT.PUT_LINE ('--> name:                    ' || db_name );
 DBMS_OUTPUT.PUT_LINE ('--> version:                 ' || db_version );

 IF db_version like '12.1.0.2%' or db_version like '12.2.0%' or db_version like '18.1.0%' or db_version like '19.%' or db_version like '21.%' THEN
   DBMS_OUTPUT.PUT_LINE ('.');
 ELSE
 DBMS_OUTPUT.PUT_LINE( '**********************************************************************');
 DBMS_OUTPUT.PUT_LINE('Your database version is ' || db_version  || '. ');
 DBMS_OUTPUT.PUT_LINE('You must be on 12.1.0.2 database version or greater in order to use JSON DB.');
 DBMS_OUTPUT.PUT_LINE('Please upgrade to at least 12.1.0.2 to use JSON DB');
 DBMS_OUTPUT.PUT_LINE( '**********************************************************************');
 goto end_proc;
 END IF;

 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Database Components:');
 display_banner;
 FOR v_feat IN c_feat LOOP
   DBMS_OUTPUT.PUT_LINE( '--> ' || rpad(v_feat.comp_name, 35) || ' '
     || rpad(v_feat.version, 10) || '   ' || rpad(v_feat.status, 10));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE('Database Character Set:');
 display_banner;

DECLARE
 char_name   VARCHAR2(4000);
BEGIN
 SELECT VALUE$ INTO char_name FROM sys.props$ where name = 'NLS_CHARACTERSET';
 DBMS_OUTPUT.PUT_LINE ('.Database '||db_name||' is using the database characterset '||char_name||'.');
  IF char_name = 'AL32UTF8' THEN
   DBMS_OUTPUT.PUT_LINE ('.' ||char_name|| ' is the recommended characterset for JSON DB.');
   DBMS_OUTPUT.PUT_LINE ('.AL32UTF8 supports all valid characters for JSON DB.');
  ELSE
   DBMS_OUTPUT.PUT_LINE ('.'||char_name|| ' should only be used if you can guarantee that all your JSON data is part of the characterset.');
   DBMS_OUTPUT.PUT_LINE ('.Since you are not using AL32UTF8, there could be possible character losses or characterset conversion errors.');
   DBMS_OUTPUT.PUT_LINE ('.It is strongly recommend to convert to database character set AL32UTF8.');
  END IF;
END;

 DBMS_OUTPUT.PUT_LINE ('.');


 display_banner;
 DBMS_OUTPUT.PUT_LINE('MAX_STRING_SIZE setting:');
 display_banner;

DECLARE
 val_name   VARCHAR2(4000);
BEGIN
 SELECT VALUE INTO val_name FROM v$parameter where name = 'max_string_size';
 DBMS_OUTPUT.PUT_LINE ('.Database '||db_name||' has parameter max_string_size set to '||val_name||'.');
  IF val_name = 'EXTENDED' THEN
   DBMS_OUTPUT.PUT_LINE ('.EXTENDED means that the 32767 byte limit introduced in Oracle Database 12.1.0.2 applies.');
  ELSE
   DBMS_OUTPUT.PUT_LINE ('.'||val_name|| ' means that the length limits for Oracle Database '); 
   DBMS_OUTPUT.PUT_LINE ('releases prior to Oracle Database 12c apply (for example, ');
   DBMS_OUTPUT.PUT_LINE ('4000 bytes for VARCHAR2/NVARCHAR2 and 2000 bytes for RAW).');
   DBMS_OUTPUT.PUT_LINE ('.JSON DB development team recommends to set max_string_size ');
   DBMS_OUTPUT.PUT_LINE ('to EXTENDED when using JSON DB.');
  END IF;
 DBMS_OUTPUT.PUT_LINE ('.EXTENDED means that the 32767 byte limit introduced in Oracle ');
   DBMS_OUTPUT.PUT_LINE ('Database 12.1.0.2 applies.');

END;

 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Summary count of JSON DB objects:');
 display_banner;
 FOR v_json_count_obj IN c_json_count LOOP
   DBMS_OUTPUT.PUT_LINE('.. ' || rpad(v_json_count_obj.object_type,14) ||
                        '   ' || lpad(v_json_count_obj.count,3));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Invalid JSON Objects:');
 display_banner;
 FOR v_json_inval IN c_json_inval LOOP
   DBMS_OUTPUT.PUT_LINE( '.. SYS.' || rpad(v_json_inval.object_name,30) ||
     ' -  ' || v_json_inval.object_type );
   v_count := c_json_inval%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no JSON DB invalid objects.');
   DBMS_OUTPUT.PUT_LINE ('.');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ('Compilation errors for JSON DB objects.');
 display_banner;
 v_count := 0;
 FOR v_json_dba_errors IN c_json_dba_errors LOOP
   EXIT WHEN (c_json_dba_errors%NOTFOUND);
   DBMS_OUTPUT.PUT_LINE( '.. ' || v_json_dba_errors.type || ' ' ||
   v_json_dba_errors.owner || '.' || v_json_dba_errors.name );
   DBMS_OUTPUT.PUT_LINE( '.... at Line/Col: ' || TO_CHAR(v_json_dba_errors.line) || '/' ||
   TO_CHAR(v_json_dba_errors.position) );
   DBMS_OUTPUT.PUT_LINE('.... ' || v_json_dba_errors.text);
   v_count := c_json_dba_errors%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no errors for JSON DB objects.');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 DBMS_OUTPUT.PUT_LINE ('.');
 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Summary count of SODA DB objects:');
 display_banner;
 v_count := 0;
 FOR v_count_obj IN c_soda_count LOOP
   DBMS_OUTPUT.PUT_LINE('.. ' || rpad(v_count_obj.object_type,14) ||
                        '   ' || lpad(v_count_obj.count,3));
   v_count := c_soda_count%ROWCOUNT;
 END LOOP;

 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('SODA DB is not installed.');
   DBMS_OUTPUT.PUT_LINE('Please install 12.1.0.2.13 Database Proactive Patch (DBBP) or greater, ');
   DBMS_OUTPUT.PUT_LINE('then follow the patch README and run datapatch to install ');
   DBMS_OUTPUT.PUT_LINE('all the required dbms_soda_% objects.');
   DBMS_OUTPUT.PUT_LINE('Reference <JSON Database Patch Bundle Details (Doc ID 1992767.1)> '); 
   DBMS_OUTPUT.PUT_LINE('for further details.');
 END IF;
  DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Invalid SODA Objects:');
 display_banner;
 v_count := 0;
 FOR v_soda_inval IN c_soda_inval LOOP
   DBMS_OUTPUT.PUT_LINE( '.. XDB.' || rpad(v_soda_inval.object_name,30) ||
     ' -  ' || v_soda_inval.object_type );
   v_count := c_soda_inval%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no SODA DB invalid objects.');
   DBMS_OUTPUT.PUT_LINE ('.');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ('Compilation errors for SODA DB objects.');
 display_banner;
 v_count := 0;
 FOR v_soda_dba_errors IN c_soda_dba_errors LOOP
   EXIT WHEN (c_soda_dba_errors%NOTFOUND);
   DBMS_OUTPUT.PUT_LINE( '.. ' || v_soda_dba_errors.type || ' ' ||
   v_soda_dba_errors.owner || '.' || v_soda_dba_errors.name );
   DBMS_OUTPUT.PUT_LINE( '.... at Line/Col: ' || TO_CHAR(v_soda_dba_errors.line) || '/' ||
   TO_CHAR(v_soda_dba_errors.position) );
   DBMS_OUTPUT.PUT_LINE('.... ' || v_soda_dba_errors.text);
   v_count := c_soda_dba_errors%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no errors for SODA DB objects.');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');


 DBMS_OUTPUT.PUT_LINE ('.');
 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Summary count of XDB objects:');
 display_banner;
 FOR v_xdb_count_obj IN c_xdb_count LOOP
   DBMS_OUTPUT.PUT_LINE('.. ' || rpad(v_xdb_count_obj.object_type,14) ||
                        '   ' || lpad(v_xdb_count_obj.count,3));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE ('.');

 DBMS_OUTPUT.PUT_LINE ('.');
 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Invalid XDB Objects:');
 display_banner;
 FOR v_xdb_inval IN c_xdb_inval LOOP
   DBMS_OUTPUT.PUT_LINE( '.. XDB.' || rpad(v_xdb_inval.object_name,30) ||
     ' -  ' || v_xdb_inval.object_type );
   v_count := c_xdb_inval%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no XDB invalid objects.');
   DBMS_OUTPUT.PUT_LINE ('.');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ('Compilation errors under XDB schema.');
 display_banner;
 v_count := 0;
 FOR v_xdb_dba_errors IN c_xdb_dba_errors LOOP
   EXIT WHEN (c_xdb_dba_errors%NOTFOUND);
   DBMS_OUTPUT.PUT_LINE( '.. ' || v_xdb_dba_errors.type || ' ' ||
   v_xdb_dba_errors.owner || '.' || v_xdb_dba_errors.name );
   DBMS_OUTPUT.PUT_LINE( '.... at Line/Col: ' || TO_CHAR(v_xdb_dba_errors.line) || '/' ||
   TO_CHAR(v_xdb_dba_errors.position) );
   DBMS_OUTPUT.PUT_LINE('.... ' || v_xdb_dba_errors.text);
   v_count := c_xdb_dba_errors%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no errors under XDB schema.');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 DBMS_OUTPUT.PUT_LINE ('.');
 display_banner;
 DBMS_OUTPUT.PUT_LINE ('JSON DB Check Constraints:');
 display_banner;
 v_count := 0;
 FOR v_json_check IN c_json_check LOOP
  DBMS_OUTPUT.PUT_LINE('.. Table: ' || v_json_check.owner
   || '.' || v_json_check.table_name);
 DBMS_OUTPUT.PUT_LINE('.... Column: ' || v_json_check.column_name || ' Datatype: ' || v_json_check.data_type);
 v_count := c_json_check%ROWCOUNT;
 END LOOP;
 IF v_count = 0 then
   DBMS_OUTPUT.PUT_LINE('There are no JSON Check Constraints.');
   v_json_check_c := 0;
 ELSE
   v_json_check_c := 1; 
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 DBMS_OUTPUT.PUT_LINE ('.');
 display_banner;
 DBMS_OUTPUT.PUT_LINE ('JSON DB Text Indexes:');
 display_banner;
 v_count := 0;
 FOR v_json_text_indexes IN c_json_text_indexes LOOP
 DBMS_OUTPUT.PUT('.. ' || v_json_text_indexes.idx_owner ||
   '.' || v_json_text_indexes.idx_name || ' is ');
 IF (v_json_text_indexes.status != 'VALID' OR
     v_json_text_indexes.domidx_status != 'VALID' OR
     v_json_text_indexes.domidx_opstatus != 'VALID') THEN
   DBMS_OUTPUT.PUT_LINE('INVALID');
   DBMS_OUTPUT.PUT_LINE('.... INDEX STATUS => '||v_json_text_indexes.status);
   DBMS_OUTPUT.PUT_LINE('.... DOMAIN INDEX STATUS => '||v_json_text_indexes.domidx_status);
   DBMS_OUTPUT.PUT_LINE('.... DOMAIN INDEX OPERATION STATUS => '
     ||v_json_text_indexes.domidx_opstatus);
 ELSE
   DBMS_OUTPUT.PUT_LINE('VALID');
 END IF;
 DBMS_OUTPUT.PUT_LINE('.... Table: ' || v_json_text_indexes.idx_table_owner
   || '.' || v_json_text_indexes.idx_table);
 DBMS_OUTPUT.PUT_LINE('.... Indexed Column: ' || v_json_text_indexes.idx_text_name || ' Datatype: ' || v_json_text_indexes.data_type);
 DBMS_OUTPUT.PUT_LINE('.... Section Group Name: ' || v_json_text_indexes.sgp_name);
 v_count := c_json_text_indexes%ROWCOUNT;
 END LOOP;
 IF v_count = 0 then
   DBMS_OUTPUT.PUT_LINE('There are no JSON Text indexes.');
   v_json_text_indexes_c := 0;
 ELSE
   v_json_text_indexes_c := 1;
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ('Most recent JSON DB text index errors (ctx_index_errors):');
 display_banner;
 v_count := 0;
 FOR v_json_text_err IN c_json_text_err LOOP
   EXIT WHEN (c_json_text_err%NOTFOUND) OR (c_json_text_err%ROWCOUNT > 9);
   DBMS_OUTPUT.PUT_LINE(to_char(v_json_text_err.ERR_TIMESTAMP,'Dy Mon DD HH24:MI:SS YYYY'));
   DBMS_OUTPUT.PUT_LINE('.. Index name: ' || v_json_text_err.name
     || '.' || v_json_text_err.idx_name || '     Rowid: ' || v_json_text_err.err_textkey);


   DBMS_OUTPUT.PUT_LINE('.. Error: ');
   DBMS_OUTPUT.PUT_LINE('   '||
     rtrim(replace(v_json_text_err.err_text,chr(10),chr(10)||'   '),chr(10)||'   '));
   v_count := c_json_text_err%ROWCOUNT;
 END LOOP;
 IF v_count = 0 THEN
   DBMS_OUTPUT.PUT_LINE('There are no JSON DB Text errors logged in CTX_INDEX_ERRORS');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ('Testing JSON Text Index Creation:');
 display_banner;
 -- Create json_healthcheck user
 SELECT COUNT (1) INTO v_count FROM dba_users
  WHERE username = 'JSON_HEALTHCHECK';
 IF v_count != 0 THEN
  DBMS_OUTPUT.PUT_LINE ('..Dropping user JSON_HEALTHCHECK');
  EXECUTE IMMEDIATE ('DROP USER json_healthcheck CASCADE');
  DBMS_OUTPUT.PUT_LINE ('....User JSON_HEALTHCHECK dropped successfully');
 END IF;
 DBMS_OUTPUT.PUT_LINE ('..Creating user JSON_HEALTHCHECK');
 v_stmt := 'GRANT dba, connect,resource,ctxapp TO json_healthcheck IDENTIFIED BY jsonxyz_healthcheck';
 EXECUTE IMMEDIATE (v_stmt);
 v_stmt := 'alter user json_healthcheck default tablespace sysaux quota unlimited on sysaux';
 EXECUTE IMMEDIATE (v_stmt);
 DBMS_OUTPUT.PUT_LINE ('....User JSON_HEALTHCHECK created successfully');
 -- Create context index
 DBMS_OUTPUT.PUT_LINE ('..Testing creation of JSON Text index');

 v_stmt :=
     'CREATE TABLE json_healthcheck.json_hc_tab (jsonhc_id NUMBER, '
   || 'date_loaded TIMESTAMP WITH TIME ZONE, '
   || 'hc_document CLOB '
   || 'constraint ensure_json_hc CHECK(hc_document IS JSON))';

 DBMS_OUTPUT.PUT_LINE('....Creating table JSON_HC_TAB');
 EXECUTE IMMEDIATE(v_stmt);
 DBMS_OUTPUT.PUT_LINE('....Inserting JSON test data');

v_stmt :=
      'INSERT INTO json_healthcheck.json_hc_tab VALUES (1, SYSTIMESTAMP,'
   || '''{ "PONumber"             : 1600, "Description"             : "Blue Magic Christmas"}'')';

 EXECUTE IMMEDIATE(v_stmt);
 EXECUTE IMMEDIATE('COMMIT');

DECLARE
 num_rows   NUMBER := 0;
BEGIN
   SELECT COUNT(*) INTO num_rows FROM  ctxsys.ctx_section_groups
  WHERE sgp_name = 'JSON_SECTION_GROUP'; 
   IF num_rows = 0 THEN
   display_banner;
   DBMS_OUTPUT.PUT_LINE ('Error Creating JSON DB Index');
   display_banner;
   DBMS_OUTPUT.PUT_LINE ('.When creating JSON DB Index you are receiving the error: ');
   DBMS_OUTPUT.PUT_LINE('.DRG-12203: section group CTXSYS.JSON_SECTION_GROUP does not exist');
   DBMS_OUTPUT.PUT_LINE('.Please reference <DRG-12203: section group CTXSYS.JSON_SECTION_GROUP does not exist (Doc ID 1957005.1)> to fix your issue.');
   display_banner;
        goto drop_hc_user; 
   END IF;
END;


 v_stmt :=
      'CREATE INDEX json_healthcheck.json_hc_idx '
 || 'ON json_healthcheck.json_hc_tab(hc_document) '
 || 'INDEXTYPE IS CTXSYS.CONTEXT '
 || 'PARAMETERS (''SECTION GROUP CTXSYS.JSON_SECTION_GROUP SYNC (ON COMMIT)'')';
 DBMS_OUTPUT.PUT_LINE('....Creating JSON text index JSON_HC_IDX');
 EXECUTE IMMEDIATE(v_stmt);
 DBMS_OUTPUT.PUT_LINE ('....JSON Text index JSON_HC_IDX created successfully');

 DBMS_OUTPUT.PUT_LINE('....Querying JSON test data');
 v_stmt :=
      'SELECT hc_document FROM json_healthcheck.json_hc_tab WHERE JSON_TEXTCONTAINS(hc_document, ''$.Description'', ''Magic'')';

 begin
 EXECUTE IMMEDIATE(v_stmt);
 DBMS_OUTPUT.PUT_LINE ('....JSON Text query on JSON_HC_IDX completed successfully');
  exception when jsontextcont_except then
   display_banner;
   DBMS_OUTPUT.PUT_LINE ('Error Querying JSON DB test data');
   display_banner;
   DBMS_OUTPUT.PUT_LINE ('.When querying JSON DB using jsontextcontains you are receiving the error: ');
   DBMS_OUTPUT.PUT_LINE('.'||SQLERRM);
   DBMS_OUTPUT.PUT_LINE('.Please reference <ORA-40467 from JSON_TEXTCONTAINS on an upgraded 12.1.0.2 database (Doc ID 1956727.1)> to fix your issue.');
   display_banner;
end;
 
 EXECUTE IMMEDIATE('COMMIT');

<<drop_hc_user>>

 DBMS_OUTPUT.PUT_LINE ('....Dropping user JSON_HEALTHCHECK');
 EXECUTE IMMEDIATE ('DROP USER JSON_healthcheck CASCADE');
 DBMS_OUTPUT.PUT_LINE ('....User JSON_HEALTHCHECK dropped successfully');
 DBMS_OUTPUT.PUT_LINE ('..JSON Text Index Creation Test complete');



 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Is JSON DB been used?:');
 display_banner;

 IF (v_json_check_c = 1 AND 
     v_json_text_indexes_c = 1) THEN
   DBMS_OUTPUT.PUT_LINE('.JSON DB is been used.');
   DBMS_OUTPUT.PUT_LINE('.There are JSON Check Constraints and JSON Text Indexes.');
  ELSIF (v_json_check_c = 1 AND 
     v_json_text_indexes_c = 0) THEN
   DBMS_OUTPUT.PUT_LINE('.JSON DB is been used.');
   DBMS_OUTPUT.PUT_LINE('.There are JSON Check Constraints but no JSON Text Indexes.');
  ELSIF (v_json_check_c = 0 AND 
     v_json_text_indexes_c = 1) THEN
   DBMS_OUTPUT.PUT_LINE('.JSON DB is been used.');
   DBMS_OUTPUT.PUT_LINE('.There are no JSON Check Constraints but there are JSON Text Indexes.');
  ELSIF (v_json_check_c = 0 AND 
     v_json_text_indexes_c = 0) THEN
   DBMS_OUTPUT.PUT_LINE('.JSON DB is not been used.');
   DBMS_OUTPUT.PUT_LINE('.There are no JSON Check Constraints and no JSON Text Indexes.');
  ELSE
   DBMS_OUTPUT.PUT_LINE('VALID');
 END IF;

 DBMS_OUTPUT.PUT_LINE ('.');

 display_banner;
 DBMS_OUTPUT.PUT_LINE ( 'Is SODA DB been used?:');
 display_banner;
declare
 v_count number := 0;
 table_does_not_exist exception; 
 pragma exception_init( table_does_not_exist, -942 );
 begin
 execute immediate 'SELECT count(*) FROM xdb.JSON$USER_COLLECTION_METADATA' into v_count;
 IF v_count = 0 THEN
  DBMS_OUTPUT.PUT_LINE('There are no collections so SODA DB is not been used.');
 ELSE
  DBMS_OUTPUT.PUT_LINE('There are collections so SODA DB is been used.');
 END IF;
 exception 
 when table_does_not_exist then
 DBMS_OUTPUT.PUT_LINE('SODA DB is not installed so it is not been used.');
end;
 
 DBMS_OUTPUT.PUT_LINE ('.');
 
<<end_proc>> 

  DBMS_OUTPUT.PUT_LINE ('Exiting JSON DB Health Check Script');

END;
/
SET SERVEROUTPUT OFF
spool off
exit


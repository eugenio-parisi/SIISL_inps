set lines 132 pages 999
col object_name for a32
exec ctx_query.explain(index_name => 'FRA_IDX1', text_query => '(XXXXXX72B14F839F)', explain_table => 'test_explain', sharelevel => 0, explain_id => '1');

select parent_id, id, operation, options, object_name, position from test_explain 
where explain_id = '1' order by parent_id;


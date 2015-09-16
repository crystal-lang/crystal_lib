@[Include("sqlite3.h")]
@[Link("sqlite3")]
lib LibSQLite3
  fun open = sqlite3_open
  fun open = sqlite3_open_v2
  fun errcode = sqlite3_errcode
  fun errmsg = sqlite3_errmsg
  fun prepare_v2 = sqlite3_prepare_v2
  fun step = sqlite3_step
  fun column_count = sqlite3_column_count
  fun column_type = sqlite3_column_type
  fun column_int64 = sqlite3_column_int64
  fun column_double = sqlite3_column_double
  fun column_text = sqlite3_column_text
  fun column_bytes = sqlite3_column_bytes
  fun column_blob = sqlite3_column_blob
  fun bind_int = sqlite3_bind_int
  fun bind_int64 = sqlite3_bind_int64
  fun bind_text = sqlite3_bind_text
  fun bind_blob = sqlite3_bind_text
  fun bind_null = sqlite3_bind_null
  fun bind_double = sqlite3_bind_double

  fun bind_parameter_index = sqlite3_bind_parameter_index
  fun reset = sqlite3_reset
  fun column_name = sqlite3_column_name
  fun last_insert_rowid = sqlite3_last_insert_rowid

  fun finalize = sqlite3_finalize
  fun close_v2 = sqlite3_close_v2
end

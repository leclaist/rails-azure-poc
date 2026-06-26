# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_19_000000) do
  create_table "aq$_schedules", primary_key: ["oid", "destination"], force: :cascade do |t|
    t.raw "oid", limit: 16, null: false
    t.string "destination", limit: 390, null: false
    t.date "start_time"
    t.string "duration", limit: 8
    t.string "next_time", limit: 128
    t.string "latency", limit: 8
    t.date "last_time"
    t.decimal "jobno"
    t.index ["jobno"], name: "aq$_schedules_check", unique: true
  end

  create_table "help", primary_key: ["topic", "seq"], force: :cascade do |t|
    t.string "topic", limit: 50, null: false
    t.decimal "seq", null: false
    t.string "info", limit: 80
  end

  create_table "mview$_adv_ajg", primary_key: "ajgid#", id: :decimal, comment: "Anchor-join graph representation", force: :cascade do |t|
    t.decimal "runid#", null: false
    t.decimal "ajgdeslen", null: false
    t.raw "ajgdes", null: false
    t.decimal "hashvalue", null: false
    t.decimal "frequency"
  end

  create_table "mview$_adv_basetable", id: false, comment: "Base tables refered by a query", force: :cascade do |t|
    t.decimal "collectionid#", null: false
    t.decimal "queryid#", null: false
    t.string "owner", limit: 128
    t.string "table_name", limit: 128
    t.decimal "table_type"
    t.index ["queryid#"], name: "mview$_adv_basetable_idx_01"
  end

  create_table "mview$_adv_clique", primary_key: "cliqueid#", id: :decimal, comment: "Table for storing canonical form of Clique queries", force: :cascade do |t|
    t.decimal "runid#", null: false
    t.decimal "cliquedeslen", null: false
    t.raw "cliquedes", null: false
    t.decimal "hashvalue", null: false
    t.decimal "frequency", null: false
    t.decimal "bytecost", null: false
    t.decimal "rowsize", null: false
    t.decimal "numrows", null: false
  end

  create_table "mview$_adv_eligible", primary_key: ["sumobjn#", "runid#"], comment: "Summary management rewrite eligibility information", force: :cascade do |t|
    t.decimal "sumobjn#", null: false
    t.decimal "runid#", null: false
    t.decimal "bytecost", null: false
    t.decimal "flags", null: false
    t.decimal "frequency", null: false
  end

# Could not dump table "mview$_adv_exceptions" because of following StandardError
#   Unknown type 'ROWID' for column 'bad_rowid'

  create_table "mview$_adv_filter", primary_key: ["filterid#", "subfilternum#"], comment: "Table for workload filter definition", force: :cascade do |t|
    t.decimal "filterid#", null: false
    t.decimal "subfilternum#", null: false
    t.decimal "subfiltertype", null: false
    t.string "str_value", limit: 1028
    t.decimal "num_value1"
    t.decimal "num_value2"
    t.date "date_value1"
    t.date "date_value2"
  end

  create_table "mview$_adv_filterinstance", id: false, comment: "Table for workload filter instance definition", force: :cascade do |t|
    t.decimal "runid#", null: false
    t.decimal "filterid#"
    t.decimal "subfilternum#"
    t.decimal "subfiltertype"
    t.string "str_value", limit: 1028
    t.decimal "num_value1"
    t.decimal "num_value2"
    t.date "date_value1"
    t.date "date_value2"
  end

  create_table "mview$_adv_fjg", primary_key: "fjgid#", id: :decimal, comment: "Representation for query join sub-graph not in AJG ", force: :cascade do |t|
    t.decimal "ajgid#", null: false
    t.decimal "fjgdeslen", null: false
    t.raw "fjgdes", null: false
    t.decimal "hashvalue", null: false
    t.decimal "frequency"
  end

  create_table "mview$_adv_gc", primary_key: "gcid#", id: :decimal, comment: "Group-by columns of a query", force: :cascade do |t|
    t.decimal "fjgid#", null: false
    t.decimal "gcdeslen", null: false
    t.raw "gcdes", null: false
    t.decimal "hashvalue", null: false
    t.decimal "frequency"
  end

  create_table "mview$_adv_info", primary_key: ["runid#", "seq#"], comment: "Internal table for passing information from the SQL analyzer", force: :cascade do |t|
    t.decimal "runid#", null: false
    t.decimal "seq#", null: false
    t.decimal "type", null: false
    t.decimal "infolen", null: false
    t.raw "info"
    t.decimal "status"
    t.decimal "flag"
  end

# Could not dump table "mview$_adv_journal" because of following StandardError
#   Unknown type 'LONG' for column 'text'

  create_table "mview$_adv_level", primary_key: ["runid#", "levelid#"], comment: "Level definition", force: :cascade do |t|
    t.decimal "runid#", null: false
    t.decimal "levelid#", null: false
    t.decimal "dimobj#"
    t.decimal "flags", null: false
    t.decimal "tblobj#", null: false
    t.raw "columnlist", limit: 70, null: false
    t.string "levelname", limit: 128
  end

  create_table "mview$_adv_log", primary_key: "runid#", id: :decimal, comment: "Log all calls to summary advisory functions", force: :cascade do |t|
    t.decimal "filterid#"
    t.date "run_begin"
    t.date "run_end"
    t.decimal "run_type"
    t.string "uname", limit: 128
    t.decimal "status", null: false
    t.string "message", limit: 2000
    t.decimal "completed"
    t.decimal "total"
    t.string "error_code", limit: 20
  end

# Could not dump table "mview$_adv_output" because of following StandardError
#   Unknown type 'LONG' for column 'query_text'

  create_table "mview$_adv_parameters", primary_key: "parameter_name", id: { type: :string, limit: 128 }, comment: "Summary advisor tuning parameters", force: :cascade do |t|
    t.decimal "parameter_type", null: false
    t.string "string_value", limit: 30
    t.date "date_value"
    t.decimal "numerical_value"
  end

# Could not dump table "mview$_adv_plan" because of following StandardError
#   Unknown type 'LONG' for column 'other'

# Could not dump table "mview$_adv_pretty" because of following StandardError
#   Unknown type 'LONG' for column 'sql_text'

  create_table "mview$_adv_rollup", primary_key: ["runid#", "clevelid#", "plevelid#"], comment: "Each row repesents either a functional dependency or join-key relationship", force: :cascade do |t|
    t.decimal "runid#", null: false
    t.decimal "clevelid#", null: false
    t.decimal "plevelid#", null: false
    t.decimal "flags", null: false
  end

  create_table "mview$_adv_sqldepend", id: false, comment: "Temporary table for workload collections", force: :cascade do |t|
    t.decimal "collectionid#"
    t.decimal "inst_id"
    t.raw "from_address", limit: 16
    t.decimal "from_hash"
    t.string "to_owner", limit: 128
    t.string "to_name", limit: 1000
    t.decimal "to_type"
    t.decimal "cardinality"
    t.index ["collectionid#", "from_address", "from_hash", "inst_id"], name: "mview$_adv_sqldepend_idx_01"
  end

# Could not dump table "mview$_adv_temp" because of following StandardError
#   Unknown type 'LONG' for column 'text'

# Could not dump table "mview$_adv_workload" because of following StandardError
#   Unknown type 'LONG' for column 'sql_text'

# Could not dump table "ol$" because of following StandardError
#   Unknown type 'LONG' for column 'sql_text'

  create_table "ol$hints", temporary: true, id: false, force: :cascade do |t|
    t.string "ol_name", limit: 128
    t.decimal "hint#"
    t.string "category", limit: 128
    t.decimal "hint_type"
    t.string "hint_text", limit: 512
    t.decimal "stage#"
    t.decimal "node#"
    t.string "table_name", limit: 128
    t.decimal "table_tin"
    t.decimal "table_pos"
    t.decimal "ref_id"
    t.string "user_table_name", limit: 260
    t.float "cost", limit: 126
    t.float "cardinality", limit: 126
    t.float "bytes", limit: 126
    t.decimal "hint_textoff"
    t.decimal "hint_textlen"
    t.string "join_pred", limit: 2000
    t.decimal "spare1"
    t.decimal "spare2"
    t.text "hint_string"
    t.index ["ol_name", "hint#"], name: "ol$hnt_num", unique: true
  end

  create_table "ol$nodes", temporary: true, id: false, force: :cascade do |t|
    t.string "ol_name", limit: 128
    t.string "category", limit: 128
    t.decimal "node_id"
    t.decimal "parent_id"
    t.decimal "node_type"
    t.decimal "node_textlen"
    t.decimal "node_textoff"
    t.string "node_name", limit: 64
  end

  create_table "redo_db", id: false, force: :cascade do |t|
    t.decimal "dbid", null: false
    t.string "global_dbname", limit: 129
    t.string "dbuname", limit: 32
    t.string "version", limit: 32
    t.decimal "thread#", null: false
    t.decimal "resetlogs_scn_bas"
    t.decimal "resetlogs_scn_wrp"
    t.decimal "resetlogs_time", null: false
    t.decimal "presetlogs_scn_bas"
    t.decimal "presetlogs_scn_wrp"
    t.decimal "presetlogs_time", null: false
    t.decimal "seqno_rcv_cur"
    t.decimal "seqno_rcv_lo"
    t.decimal "seqno_rcv_hi"
    t.decimal "seqno_done_cur"
    t.decimal "seqno_done_lo"
    t.decimal "seqno_done_hi"
    t.decimal "gap_seqno"
    t.decimal "gap_ret"
    t.decimal "gap_done"
    t.decimal "apply_seqno"
    t.decimal "apply_done"
    t.decimal "purge_done"
    t.decimal "has_child"
    t.decimal "error1"
    t.decimal "status"
    t.date "create_date"
    t.decimal "ts1"
    t.decimal "ts2"
    t.decimal "gap_next_scn"
    t.decimal "gap_next_time"
    t.decimal "curscn_time"
    t.decimal "resetlogs_scn", null: false
    t.decimal "presetlogs_scn", null: false
    t.decimal "gap_ret2"
    t.decimal "curlog"
    t.decimal "endian"
    t.decimal "enqidx"
    t.decimal "spare4"
    t.date "spare5"
    t.string "spare6", limit: 65
    t.string "spare7", limit: 129
    t.decimal "ts3"
    t.decimal "curblkno"
    t.decimal "spare8"
    t.decimal "spare9"
    t.decimal "spare10"
    t.decimal "spare11"
    t.decimal "spare12"
    t.decimal "tenant_key", null: false
    t.index ["tenant_key", "dbid", "thread#", "resetlogs_scn", "resetlogs_time"], name: "redo_db_idx", tablespace: "sysaux"
  end

  create_table "redo_log", id: false, force: :cascade do |t|
    t.decimal "dbid", null: false
    t.string "global_dbname", limit: 129
    t.string "dbuname", limit: 32
    t.string "version", limit: 32
    t.decimal "thread#", null: false
    t.decimal "resetlogs_scn_bas"
    t.decimal "resetlogs_scn_wrp"
    t.decimal "resetlogs_time", null: false
    t.decimal "presetlogs_scn_bas"
    t.decimal "presetlogs_scn_wrp"
    t.decimal "presetlogs_time", null: false
    t.decimal "sequence#", null: false
    t.decimal "dupid"
    t.decimal "status1"
    t.decimal "status2"
    t.string "create_time", limit: 32
    t.string "close_time", limit: 32
    t.string "done_time", limit: 32
    t.decimal "first_scn_bas"
    t.decimal "first_scn_wrp"
    t.decimal "first_time"
    t.decimal "next_scn_bas"
    t.decimal "next_scn_wrp"
    t.decimal "next_time"
    t.decimal "first_scn"
    t.decimal "next_scn"
    t.decimal "resetlogs_scn", null: false
    t.decimal "blocks"
    t.decimal "block_size"
    t.decimal "old_blocks"
    t.date "create_date"
    t.decimal "error1"
    t.decimal "error2"
    t.string "filename", limit: 513
    t.decimal "ts1"
    t.decimal "ts2"
    t.decimal "endian"
    t.decimal "spare2"
    t.decimal "spare3"
    t.decimal "spare4"
    t.date "spare5"
    t.string "spare6", limit: 65
    t.string "spare7", limit: 129
    t.decimal "ts3"
    t.decimal "presetlogs_scn", null: false
    t.decimal "spare8"
    t.decimal "spare9"
    t.decimal "spare10"
    t.decimal "old_status1"
    t.decimal "old_status2"
    t.string "old_filename", limit: 513
    t.decimal "tenant_key", null: false
    t.index ["tenant_key", "dbid", "thread#", "resetlogs_scn", "resetlogs_time"], name: "redo_log_idx", tablespace: "sysaux"
  end

# Could not dump table "scheduler_job_args_tbl" because of following StandardError
#   Unknown type 'SYS.ANYDATA' for column 'anydata_value'

# Could not dump table "scheduler_program_args_tbl" because of following StandardError
#   Unknown type 'SYS.ANYDATA' for column 'default_anydata_value'

# Could not dump table "sqlplus_product_profile" because of following StandardError
#   Unknown type 'LONG' for column 'long_value'

  create_table "visits", force: :cascade do |t|
    t.string "ip_address", limit: 45
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "mview$_adv_ajg", "mview$_adv_log", column: "runid#", primary_key: "runid#", name: "mview$_adv_ajg_fk"
  add_foreign_key "mview$_adv_basetable", "mview$_adv_workload", column: "queryid#", primary_key: "queryid#", name: "mview$_adv_basetable_fk"
  add_foreign_key "mview$_adv_clique", "mview$_adv_log", column: "runid#", primary_key: "runid#", name: "mview$_adv_clique_fk"
  add_foreign_key "mview$_adv_eligible", "mview$_adv_log", column: "runid#", primary_key: "runid#", name: "mview$_adv_eligible_fk"
  add_foreign_key "mview$_adv_exceptions", "mview$_adv_log", column: "runid#", primary_key: "runid#", name: "mview$_adv_exception_fk"
  add_foreign_key "mview$_adv_filterinstance", "mview$_adv_log", column: "runid#", primary_key: "runid#", name: "mview$_adv_filterinstance_fk"
  add_foreign_key "mview$_adv_fjg", "mview$_adv_ajg", column: "ajgid#", primary_key: "ajgid#", name: "mview$_adv_fjg_fk"
  add_foreign_key "mview$_adv_gc", "mview$_adv_fjg", column: "fjgid#", primary_key: "fjgid#", name: "mview$_adv_gc_fk"
  add_foreign_key "mview$_adv_info", "mview$_adv_log", column: "runid#", primary_key: "runid#", name: "mview$_adv_info_fk"
  add_foreign_key "mview$_adv_journal", "mview$_adv_log", column: "runid#", primary_key: "runid#", name: "mview$_adv_journal_fk"
  add_foreign_key "mview$_adv_level", "mview$_adv_log", column: "runid#", primary_key: "runid#", name: "mview$_adv_level_fk"
  add_foreign_key "mview$_adv_output", "mview$_adv_log", column: "runid#", primary_key: "runid#", name: "mview$_adv_output_fk"
  add_foreign_key "mview$_adv_rollup", "mview$_adv_level", column: "clevelid#", primary_key: "levelid#", name: "mview$_adv_rollup_cfk"
  add_foreign_key "mview$_adv_rollup", "mview$_adv_level", column: "plevelid#", primary_key: "levelid#", name: "mview$_adv_rollup_pfk"
  add_foreign_key "mview$_adv_rollup", "mview$_adv_level", column: "runid#", primary_key: "runid#", name: "mview$_adv_rollup_cfk"
  add_foreign_key "mview$_adv_rollup", "mview$_adv_level", column: "runid#", primary_key: "runid#", name: "mview$_adv_rollup_pfk"
  add_foreign_key "mview$_adv_rollup", "mview$_adv_log", column: "runid#", primary_key: "runid#", name: "mview$_adv_rollup_fk"
  add_synonym "syscatalog", "sys.syscatalog", force: true
  add_synonym "catalog", "sys.catalog", force: true
  add_synonym "tab", "sys.tab", force: true
  add_synonym "col", "sys.col", force: true
  add_synonym "tabquotas", "sys.tabquotas", force: true
  add_synonym "sysfiles", "sys.sysfiles", force: true
  add_synonym "publicsyn", "sys.publicsyn", force: true
  add_synonym "aq$_queue_tables", "sys.aq$_queue_tables", force: true
  add_synonym "aq$_queues", "sys.aq$_queues", force: true
  add_synonym "aq$_key_shard_map", "sys.aq$_key_shard_map", force: true
  add_synonym "aq$_internet_agents", "sys.aq$_internet_agents", force: true
  add_synonym "aq$_internet_agent_privs", "sys.aq$_internet_agent_privs", force: true
  add_synonym "product_user_profile", "system.sqlplus_product_profile", force: true

end

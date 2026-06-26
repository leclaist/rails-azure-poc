# Oracle Enhanced Adapter's purge() fires ORA-65040 when connected as a
# non-SYS user to a PDB. Replace db:test:prepare with a plain migrate so
# the test runner can set up the schema without touching CDB-level DDL.
Rake::Task["db:test:prepare"].clear
namespace :db do
  namespace :test do
    task prepare: "db:migrate"
  end
end

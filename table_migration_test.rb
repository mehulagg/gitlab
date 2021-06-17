# frozen_string_literal: true
drop_table = "DROP TABLE IF EXISTS ci_test_table"

create_table = """
CREATE TABLE ci_test_table (
id serial,
name text,
primary key(id)
)
"""

# Function that raises the error hint. If it's raised, we force-reconnect to the CI DB
create_function = """
CREATE OR REPLACE FUNCTION use_ci_db() RETURNS trigger AS $use_ci_db$
  BEGIN
    RAISE EXCEPTION 'connect_to: ci';
  END;
$use_ci_db$ LANGUAGE plpgsql;
"""
ActiveRecord::Base.logger = Logger.new($stdout)
CiBase.establish_connection

# Create a new table
CiTestTable.connection.execute(drop_table)
CiTestTable.connection.execute(create_table)
CiTestTable.connection.execute(create_function)
puts "Table created for primary DB"

# Create the same table on the other DB
CiBase.connected_to(role: :writing, shard: :ci) do
  CiTestTable.connection.execute(drop_table)
  CiTestTable.connection.execute(create_table)
end
puts "Table created for ci DB"

# Create 10 records on the primary
10.times do
  CiTestTable.create!(name: 'foo')
end

# Infinite loop for reading the table
read_thread = Thread.new do
  Rails.application.executor.wrap do
    loop do
      CiTestTable.last
    rescue Exception => ex
      # Connection switch happens here
      if ex.message.include?("connect_to: ci")
        CiBase.establish_connection(:ci)
        CiTestTable.establish_connection(:ci)
        puts "reconnect"

        retry
      end
    end
  end
end

records_from_primary = nil

CiBase.transaction do
  # Block writes on the primary
  CiBase.connection.execute("LOCK TABLE ci_test_table IN EXCLUSIVE MODE")

  # Collect and insert the data. This would be done by the replication...
  records_from_primary = CiTestTable.all.map(&:attributes)
  CiBase.connected_to(role: :writing, shard: :ci) do
    records_from_primary.each do |row|
      CiTestTable.create!(row)
    end

    # Update the primary key sequence on the new table
    next_sequence_value = CiTestTable.maximum(:id) + 1
    CiTestTable.connection.execute("ALTER SEQUENCE ci_test_table_id_seq RESTART WITH #{next_sequence_value}")
  end

  # Prevent writes on the primary
  CiTestTable.connection.execute("""
                                 CREATE TRIGGER use_ci_db_trigger
                                 AFTER INSERT OR UPDATE OR DELETE ON ci_test_table
                                 FOR EACH ROW EXECUTE PROCEDURE use_ci_db();
                                 """)
end

# Insert 10 more rows, these should go into the CI DB
10.times do
  CiTestTable.create!(name: 'foo')
rescue Exception => ex
  # Connection switch happens here
  if ex.message.include?("connect_to: ci")
    CiBase.establish_connection(:ci)
    CiTestTable.establish_connection(:ci)

    puts "reconnect"
    retry
  end
end

puts "Killing reader thread"
read_thread.kill

records_from_ci_table = CiTestTable.all.map(&:attributes)

records_from_primary.each_with_index do |row, i|
  raise "Row was not copied from primary: #{row}" if records_from_ci_table[i] != row
end

raise "Some rows were not inserted" if records_from_ci_table.size != 20

puts "Data is consistent"

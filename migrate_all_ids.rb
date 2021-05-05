def ids_up(table)
  conn=ActiveRecord::Base.connection;

  conn.columns(table).each do |column|
    next unless column.name == 'id' || column.name.ends_with?('_id')
    next unless column.sql_type_metadata.sql_type == 'integer'

    puts "\tchange_column :#{table}, :#{column.name}, :bigint"
  end
end

def ids_down(table)
  conn=ActiveRecord::Base.connection;

  conn.columns(table).each do |column|
    next unless column.name == 'id' || column.name.ends_with?('_id')
    next unless column.sql_type_metadata.sql_type == 'integer'

    puts "\tchange_column :#{table}, :#{column.name}, :#{column.sql_type_metadata.sql_type}"
  end
end

def seq_up(table)
  conn=ActiveRecord::Base.connection;

  conn.columns(table).each do |column|
    next unless column.serial?

    puts "\texecute(\"ALTER TABLE #{table} ALTER COLUMN #{column.name} SET DEFAULT shard_next_id()\")"
  end
end

def seq_down(table)
  conn=ActiveRecord::Base.connection;

  conn.columns(table).each do |column|
    next unless column.serial?

    puts "\texecute(\"ALTER TABLE #{table} ALTER COLUMN #{column.name} SET DEFAULT #{column.default_function}\")"
  end
end

puts "def up"
ActiveRecord::Base.connection.tables.sort.each do |table|
  ids_up(table)
end
puts "end"
puts

puts "def down"
ActiveRecord::Base.connection.tables.sort.each do |table|
  ids_down(table)
end
puts "end"
puts

puts "def up"
puts <<-EOS
  execute <<-EOF
    CREATE OR REPLACE FUNCTION shard_next_id(OUT result bigint) AS $$
    DECLARE
        our_epoch bigint := 1620213659000;
        seq_id bigint;
        now_millis bigint;
        shard_id int := 0;
    BEGIN
        SELECT nextval('shard_id_seq') % 1024 INTO seq_id;
        SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
        result := (now_millis - our_epoch) << 23;
        result := result | (shard_id <<10);
        result := result | (seq_id);
    END;
        $$ LANGUAGE PLPGSQL;
  EOF
EOS

ActiveRecord::Base.connection.tables.sort.each do |table|
  seq_up(table)
end
puts "end"
puts

puts "def down"

ActiveRecord::Base.connection.tables.sort.each do |table|
  seq_down(table)
end
puts "end"

namespace :gitlab do
  namespace :distributed_hll do
    desc 'GitLab | DistributedHll | Calculates Standard Error'
    task standard_error: :environment do
      TABLE_NAME = "test_table_#{Time.current.to_i}"
      CretateTestTable = Class.new(ActiveRecord::Migration[6.0]) do
        def up
          create_table TABLE_NAME do |t|
            t.integer :some_val
          end
        end

        def down
          drop_table TABLE_NAME
        end
      end

      migration = CretateTestTable.new

      ModelClass = Class.new(ApplicationRecord) do
        self.table_name = TABLE_NAME
      end
      migration.up

      samples_cnt = 500

      [10, 100, 1000, 10_000].each do |max_card|
        puts "Max cardinality: #{max_card}"
        samples = []
        sum_of_deviations = 0
        samples_cnt.times do
          insert_attrs = (0..max_card).map{ |val| rand % 5 == 0 ? "(#{val}),(#{val})" : "(#{val})" }.join(',')

          ActiveRecord::Base.connection.execute("INSERT INTO #{TABLE_NAME} (some_val) VALUES #{insert_attrs}")
          est = Gitlab::Database::PostgresHll::BatchDistinctCounter.new(ModelClass).execute.estimated_distinct_count
          ActiveRecord::Base.connection.execute("TRUNCATE #{TABLE_NAME}")
          samples << est
          sum_of_deviations += (est - max_card)**2
        end

        # variance = (samples.sum { |est, card| (est - card)**2  }) / samples_cnt
        variance = sum_of_deviations / samples_cnt

        puts "Variance: #{variance}"
        puts "Expected standard error: #{ 1.04 / Math.sqrt(::Gitlab::Database::PostgresHll::Buckets::TOTAL_BUCKETS)}"
        puts "Empirical standard error: #{ Math.sqrt(variance) / max_card }"
      end

      # puts "Standard error: #{ Math.sqrt(variance) / samples_cnt }"
    ensure
      migration.down
    end
  end
end

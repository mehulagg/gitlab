# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::Reindexing::ReindexConcurrently, '#perform' do
  subject { described_class.new(index, logger: logger).perform }

  let(:table_name) { '_test_reindex_table' }
  let(:column_name) { '_test_column' }
  let(:index_name) { '_test_reindex_index' }
  let(:index) { instance_double(Gitlab::Database::PostgresIndex, indexrelid: 42, name: index_name, schema: 'public', tablename: table_name, partitioned?: false, unique?: false, exclusion?: false, expression?: false, definition: 'CREATE INDEX _test_reindex_index ON public._test_reindex_table USING btree (_test_column)') }
  let(:logger) { double('logger', debug: nil, info: nil, error: nil ) }
  let(:connection) { ActiveRecord::Base.connection }

  before do
    connection.execute(<<~SQL)
      CREATE TABLE #{table_name} (
        id serial NOT NULL PRIMARY KEY,
        #{column_name} integer NOT NULL);

      CREATE INDEX #{index.name} ON #{table_name} (#{column_name});
    SQL
  end

  context 'when the index serves an exclusion constraint' do
    before do
      allow(index).to receive(:exclusion?).and_return(true)
    end

    it 'raises an error' do
      expect { subject }.to raise_error(described_class::ReindexError, /indexes serving an exclusion constraint are currently not supported/)
    end
  end

  context 'when attempting to reindex an expression index' do
    before do
      allow(index).to receive(:expression?).and_return(true)
    end

    it 'raises an error' do
      expect { subject }.to raise_error(described_class::ReindexError, /expression indexes are currently not supported/)
    end
  end

  context 'when the index is a dangling temporary index from a previous reindexing run' do
    context 'with the temporary index prefix' do
      let(:index_name) { '_test_reindex_index_ccnew' }

      it 'raises an error' do
        expect { subject }.to raise_error(described_class::ReindexError, /left-over temporary index/)
      end
    end

    context 'with the temporary index prefix with a counter' do
      let(:index_name) { '_test_reindex_index_ccnew1' }

      it 'raises an error' do
        expect { subject }.to raise_error(described_class::ReindexError, /left-over temporary index/)
      end
    end
  end

  it 'recreates the index using REINDEX with a long statement timeout' do
    expect_to_execute_in_order(
      "SET statement_timeout TO '32400s'",
      "REINDEX INDEX CONCURRENTLY \"public\".\"#{index.name}\"",
      "RESET statement_timeout"
    )

    subject
  end

  context 'with dangling indexes  matching TEMPORARY_INDEX_PATTERN, i.e. /some\_index\_ccnew(\d)*/' do
    before do
      # dangling indexes
      connection.execute("CREATE INDEX #{index_name}_ccnew ON #{table_name} (#{column_name})")
      connection.execute("CREATE INDEX #{index_name}_ccnew2 ON #{table_name} (#{column_name})")

      # Unrelated index - don't drop
      connection.execute("CREATE INDEX some_other_index_ccnew ON #{table_name} (#{column_name})")
    end

    it 'drops the dangling indexes while controlling lock_timeout' do
      expect_to_execute_in_order(
        # Regular index rebuild
        "SET statement_timeout TO '32400s'",
        "REINDEX INDEX CONCURRENTLY \"public\".\"#{index.name}\"",
        "RESET statement_timeout",
        # Drop _ccnew index
        "SET lock_timeout TO '60000ms'",
        "DROP INDEX CONCURRENTLY IF EXISTS \"public\".\"#{index.name}_ccnew\"",
        "RESET idle_in_transaction_session_timeout; RESET lock_timeout",
        # Drop _ccnew2 index
        "SET lock_timeout TO '60000ms'",
        "DROP INDEX CONCURRENTLY IF EXISTS \"public\".\"#{index.name}_ccnew2\"",
        "RESET idle_in_transaction_session_timeout; RESET lock_timeout"
      )

      subject
    end
  end

  def expect_to_execute_in_order(*queries)
    # Indexes cannot be created CONCURRENTLY in a transaction. Since the tests are wrapped in transactions,
    # verify the original call but pass through the non-concurrent form.
    queries.each do |query|
      expect(connection).to receive(:execute).with(query).ordered.and_wrap_original do |method, sql|
        method.call(sql.sub(/CONCURRENTLY/, ''))
      end
    end
  end

  def expect_index_rename(from, to)
    expect(connection).to receive(:execute).with(<<~SQL).ordered
      ALTER INDEX "public"."#{from}"
      RENAME TO "#{to}"
    SQL
  end

  def expect_index_drop(drop_index)
    expect_next_instance_of(::Gitlab::Database::WithLockRetries) do |instance|
      expect(instance).to receive(:run).with(raise_on_exhaustion: false).and_yield
    end

    expect_to_execute_concurrently_in_order(drop_index)
  end

  def find_index_create_statement
    ActiveRecord::Base.connection.select_value(<<~SQL)
      SELECT indexdef
      FROM pg_indexes
      WHERE schemaname = 'public'
      AND indexname = #{ActiveRecord::Base.connection.quote(index.name)}
    SQL
  end

  def check_index_exists
    expect(find_index_create_statement).to eq(original_index)
  end
end

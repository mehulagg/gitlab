# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '' do
  # Simulating a scenario where we rename Tickets to Issues
  let(:model_using_the_old_table) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'tickets'

      attr_accessor :updated_by

      enum issue_type: { issue: 0, incident: 1, test_case: 2 }
    end
  end

  let(:model_using_the_new_table) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'issues'

      attr_accessor :updated_by

      enum issue_type: { issue: 0, incident: 1, test_case: 2 }
    end
  end

  before do
    # tickets table was already renmaed to issues, creating a view for backward compatibility
    ActiveRecord::Base.connection.execute("CREATE VIEW tickets AS SELECT * FROM issues")
    ActiveRecord::Base.connection.execute("insert into renamed_tables (old_name, new_name) values ('tickets', 'issues')")

    model_using_the_old_table.reset_column_information
    ActiveRecord::Base.connection.schema_cache.clear!
  end

  it 'has primary key' do
    expect(model_using_the_old_table.primary_key).to eq('id')
    expect(model_using_the_old_table.primary_key).to eq(model_using_the_new_table.primary_key)
  end

  it 'has the same column definitions' do
    expect(model_using_the_old_table.columns).to eq(model_using_the_new_table.columns)
  end

  it 'has the same indexes' do
    indexes_for_old_table = ActiveRecord::Base.connection.schema_cache.indexes('tickets')
    indexes_for_new_table = ActiveRecord::Base.connection.schema_cache.indexes('issues')

    expect(indexes_for_old_table).to eq(indexes_for_new_table)
  end

  it 'has the same column_hash' do
    columns_hash_for_old_table = ActiveRecord::Base.connection.schema_cache.columns_hash('tickets')
    columns_hash_for_new_table = ActiveRecord::Base.connection.schema_cache.columns_hash('issues')

    expect(columns_hash_for_old_table).to eq(columns_hash_for_new_table)
  end

  it 'builds the same model attributes' do
    expect(model_using_the_old_table.new.attributes).to eq(model_using_the_new_table.new.attributes)
  end

  describe 'table backed by a view' do
    let_it_be(:project) { create(:project) }

    let(:record) { model_using_the_old_table.create!(attributes_for(:issue, project: project, author_id: project.creator.id)) }

    it 'can persist records' do
      expect(record.reload.attributes).to eq(model_using_the_new_table.find(record.id).attributes)
    end

    it 'can find records' do
      expect(model_using_the_old_table.find_by_id(record.id)).not_to be_nil
    end
  end
end

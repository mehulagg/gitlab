# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::RenameTablePatch do
  let(:old_model) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'projects'
    end
  end

  let(:new_model) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'projects_new'
    end
  end

  before do
    stub_const('Gitlab::Database::TABLES_TO_BE_RENAMED', { 'projects' => 'projects_new' })
  end

  context 'when table is not renamed yet' do
    before do
      old_model.reset_column_information
      ActiveRecord::Base.connection.schema_cache.clear!
    end

    it 'uses the original table to look up metadata' do
      expect(old_model.primary_key).to eq('id')
    end
  end

  context 'when table is renamed' do
    before do
      ActiveRecord::Base.connection.execute("ALTER TABLE projects RENAME TO projects_new")
      ActiveRecord::Base.connection.execute("CREATE VIEW projects AS SELECT * FROM projects_new")

      old_model.reset_column_information
      ActiveRecord::Base.connection.schema_cache.clear!
    end

    it 'uses the renamed table to look up metadata' do
      expect(old_model.primary_key).to eq('id')
    end

    it 'has primary key' do
      expect(old_model.primary_key).to eq('id')
      expect(old_model.primary_key).to eq(new_model.primary_key)
    end

    it 'has the same column definitions' do
      expect(old_model.columns).to eq(new_model.columns)
    end

    it 'has the same indexes' do
      indexes_for_old_table = ActiveRecord::Base.connection.schema_cache.indexes('projects')
      indexes_for_new_table = ActiveRecord::Base.connection.schema_cache.indexes('projects_new')

      expect(indexes_for_old_table).to eq(indexes_for_new_table)
    end

    it 'has the same column_hash' do
      columns_hash_for_old_table = ActiveRecord::Base.connection.schema_cache.columns_hash('projects')
      columns_hash_for_new_table = ActiveRecord::Base.connection.schema_cache.columns_hash('projects_new')

      expect(columns_hash_for_old_table).to eq(columns_hash_for_new_table)
    end

    context 'when calling methods on the connection' do
      let(:connection) { ActiveRecord::Base.connection }

      it 'returns the correct primary key' do
        expect(connection.primary_key('projects')).to eq('id')
      end

      it 'returns the correct indexes' do
        index_names = connection.indexes('projects').map(&:name)
        expected_index_names = connection.indexes('projects_new').map(&:name)

        expect(index_names).to eq(expected_index_names)
      end

      it 'returns the correct foreign keys' do
        expect(connection.foreign_keys('projects')).to eq(connection.foreign_keys('projects_new'))
      end

      it 'returns the correct columns' do
        expect(connection.columns('projects')).to eq(connection.columns('projects_new'))
      end
    end

    describe 'when the table behind a model is actually a view' do
      let(:group) { create(:group) }
      let(:project_attributes) { attributes_for(:project, namespace_id: group.id).except(:creator) }
      let(:record) { old_model.create!(project_attributes) }

      it 'can persist records' do
        expect(record.reload.attributes).to eq(new_model.find(record.id).attributes)
      end

      it 'can find records' do
        expect(old_model.find_by_id(record.id)).not_to be_nil
      end
    end
  end
end

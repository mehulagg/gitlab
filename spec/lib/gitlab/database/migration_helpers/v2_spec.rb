# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::MigrationHelpers::V2 do
  include Database::TriggerHelpers

  let(:migration) do
    ActiveRecord::Migration.new.extend(described_class)
  end

  let(:model) { Class.new(ActiveRecord::Base) }
  let(:connection) { migration.connection }

  before do
    allow(migration).to receive(:puts)

    migration.create_table :test_table do |t|
      t.integer :status, null: false
      t.text :original
      t.text :other_column
    end

    model.table_name = :test_table
  end

  describe '#rename_column_concurrently' do
    before do
      allow(migration).to receive(:transaction_open?).and_return(false)
    end

    context 'when called inside a transaction block' do
      before do
        allow(migration).to receive(:transaction_open?).and_return(true)
      end

      it 'raises an error' do
        expect do
          migration.rename_column_concurrently :test_table, :original, :renamed
        end.to raise_error('rename_column_concurrently can not be run inside a transaction')
      end
    end

    context 'when the target column does not exist' do
      it 'raises an error' do
        expect do
          migration.rename_column_concurrently :test_table, :missing_column, :renamed
        end.to raise_error('Column missing_column does not exist on test_table')
      end
    end

    context 'when the target column has a default value' do
      before do
        migration.change_column_default :test_table, :original, 'default value'
      end

      it 'raises an error' do
        expect do
          migration.rename_column_concurrently :test_table, :original, :renamed
        end.to raise_error('rename_column_concurrently does not currently support columns with default values')
      end
    end

    context 'when the batch column does not exist' do
      it 'raises an error' do
        expect do
          migration.rename_column_concurrently :test_table, :original, :renamed, batch_column_name: :missing
        end.to raise_error('Column missing does not exist on test_table')
      end
    end

    it 'creates the renamed column, syncing existing data' do
      existing_record_1 = model.create!(status: 0, original: 'existing')
      existing_record_2 = model.create!(status: 0, original: nil)

      migration.rename_column_concurrently :test_table, :original, :renamed
      model.reset_column_information

      expect(migration.column_exists?(:test_table, :renamed)).to eq(true)

      expect(existing_record_1.reload).to have_attributes(status: 0, original: 'existing', renamed: 'existing')
      expect(existing_record_2.reload).to have_attributes(status: 0, original: nil, renamed: nil)
    end

    it 'installs triggers to sync new data' do
      migration.rename_column_concurrently :test_table, :original, :renamed
      model.reset_column_information

      new_record_1 = model.create!(status: 1, original: 'first')
      new_record_2 = model.create!(status: 1, renamed: 'second')

      expect(new_record_1.reload).to have_attributes(status: 1, original: 'first', renamed: 'first')
      expect(new_record_2.reload).to have_attributes(status: 1, original: 'second', renamed: 'second')

      new_record_1.update!(original: 'updated')
      new_record_2.update!(renamed: nil)

      expect(new_record_1.reload).to have_attributes(status: 1, original: 'updated', renamed: 'updated')
      expect(new_record_2.reload).to have_attributes(status: 1, original: nil, renamed: nil)
    end
  end

  describe '#undo_rename_column_concurrently' do
    context 'when the renamed column does not exist' do
      it 'does not raise an error' do
        expect(migration).not_to receive(:remove_column)

        expect do
          migration.undo_rename_column_concurrently :test_table, :original, :renamed
        end.not_to raise_error
      end
    end

    context 'when the renamed column exists' do
      let(:triggers) do
        [
          ['trigger_7cc71f92fd63', 'function_for_trigger_7cc71f92fd63', before: 'insert'],
          ['trigger_f1a1f619636a', 'function_for_trigger_f1a1f619636a', before: 'update'],
          ['trigger_769a49938884', 'function_for_trigger_769a49938884', before: 'update']
        ]
      end

      before do
        allow(migration).to receive(:transaction_open?).and_return(false)

        migration.rename_column_concurrently :test_table, :original, :renamed
      end

      it 'removes the sync triggers and renamed columns' do
        triggers.each do |(trigger_name, function_name, event)|
          expect_function_to_exist(function_name)
          expect_valid_function_trigger(:test_table, trigger_name, function_name, event)
        end

        expect(migration.column_exists?(:test_table, :renamed)).to eq(true)

        migration.undo_rename_column_concurrently :test_table, :original, :renamed

        expect(migration.column_exists?(:test_table, :renamed)).to eq(false)

        triggers.each do |(trigger_name, function_name, _)|
          expect_trigger_not_to_exist(:test_table, trigger_name)
          expect_function_not_to_exist(function_name)
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::MigrationAttributes do
  let!(:migration_class) do
    Class.new do
      include Elastic::MigrationAttributes
    end
  end

  describe '.migration_options' do
    it 'sets options for class' do
      options = { test: true }
      migration_class.migration_options(options)

      # must check through `get_migration_options` method to verify values were set properly
      expect(migration_class.get_migration_options).to eq(options)
    end

    it 'returns empty hash if no options are set' do
      migration_class.migration_options

      # must check through `get_migration_options` method to verify values were set properly
      expect(migration_class.get_migration_options).to eq({})
    end
  end

  describe '.get_migration_options' do
    it 'has returns empty hash has if no options are set' do
      expect(migration_class.get_migration_options).to eq({})
    end
  end
end

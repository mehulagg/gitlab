# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::MigrationOptions do
  let!(:migration_class) do
    Class.new do
      include Elastic::MigrationOptions
    end
  end

  # must check through `get_migration_options` method to verify values
  subject { migration_class.get_migration_options }

  describe '.migration_options' do
    it 'sets options for class' do
      options = { test: true }
      migration_class.migration_options(options)

      expect(subject).to eq(options)
    end

    it 'has a default for throttle_delay' do
      migration_class.migration_options

      expect(subject).to eq({ throttle_delay: Elastic::MigrationOptions::DEFAULT_THROTTLE_DELAY })
    end
  end

  describe '.get_migration_options' do
    it 'has returns empty hash if migration_options was never called' do
      expect(subject).to eq({})
    end
  end
end

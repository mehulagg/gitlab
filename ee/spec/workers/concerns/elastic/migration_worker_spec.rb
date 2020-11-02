# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::MigrationWorker do
  let(:worker) do
    Class.new do
      def perform
      end

      def self.name
        'DummyMigrationWorker'
      end

      prepend Elastic::MigrationWorker
    end.new
  end

  describe '.perform' do
    it 'fails if TIMESTAMP is not specified' do
      expect { worker.perform }.to raise_error(StandardError, /TIMESTAMP is required/)
    end
  end
end

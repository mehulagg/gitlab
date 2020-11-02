# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::MigrationWorker do
  let!(:issue) { build(:issue) }

  let(:worker) do
    Class.new do
      TIMESTAMP = 1604317615 # rubocop: disable RSpec/LeakyConstantDeclaration

      def perform(object)
        object.touch
      end

      def self.name
        'DummyMigrationWorker'
      end

      prepend Elastic::MigrationWorker
    end.new
  end

  let(:incorrect_worker) do
    Class.new do
      def perform(object)
        object.touch
      end

      def self.name
        'IncorrectDummyMigrationWorker'
      end

      prepend Elastic::MigrationWorker
    end.new
  end

  describe '.perform' do
    it 'fails if TIMESTAMP is not specified' do
      expect(issue).not_to receive(:touch)
      expect { incorrect_worker.perform(issue) }.to raise_error(StandardError, /TIMESTAMP is required/)
    end

    it 'works with timestamp' do
      expect(issue).to receive(:touch)
      expect { worker.perform(issue) }.not_to raise_error
    end
  end
end

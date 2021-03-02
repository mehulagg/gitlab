# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::Migration, :elastic do
  let(:logger) { double('Gitlab::Elasticsearch::Logger') }
  let(:migration_class) do
    Class.new(described_class) do
      def migrate
        log "number_of_nodes: #{client.cluster.health['number_of_nodes']}"

        raise 'Index does not exist' unless helper.migrations_index_exists?
      end
    end
  end

  let(:version) { 20201105181100 }
  let(:migration) { migration_class.new(version) }
  let(:bare_migration) { described_class.new(version) }

  before do
    allow(::Gitlab::Elasticsearch::Logger).to receive(:build).and_return(logger)
  end

  describe '#migrate' do
    it 'executes method' do
      expect(logger).to receive(:info).with(/number_of_nodes/)
      expect { migration.migrate }.not_to raise_error
    end

    it 'raises exception for original class' do
      expect { bare_migration.migrate }.to raise_error(NotImplementedError)
    end
  end

  describe '#completed?' do
    it 'raises exception for original class' do
      expect { bare_migration.completed? }.to raise_error(NotImplementedError)
    end
  end

  describe '#storage_required_bytes?' do
    context 'when check_storage! migration option is not set' do
      it 'does not raise exception for original class' do
        expect { bare_migration.storage_required_bytes }.not_to raise_error
      end
    end

    context 'when check_storage! migration option is set' do
      it 'raises exception for original class' do
        allow(bare_migration).to receive(:check_storage?).and_return(true)

        expect { bare_migration.storage_required_bytes }.to raise_error(NotImplementedError)
      end
    end
  end
end

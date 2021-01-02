require 'spec_helper'

RSpec.describe Gitlab::Database::Migrations::Instrumentation do

  describe '#observe' do
    subject { described_class.new.observe(migration, migration_block) }

    let(:migration_block) { double('block', call: nil) }
    let(:migration) { 1234 }

    it 'executes the given block' do
      expect(migration_block).to receive(:call)

      subject
    end

    context 'on successful execution' do
      it 'records walltime' do
        expect(subject.walltime).not_to be_nil
      end

      it 'records success' do
        expect(subject.success).to be_truthy
      end

      it 'records the migration version' do
        expect(subject.migration).to eq(migration)
      end
    end

    context 'upon failure' do
       before do
        allow(migration_block).to receive(:call).and_raise(/something went wrong/)
      end

      it 'records walltime' do
        expect(subject.walltime).not_to be_nil
      end

      it 'records failure' do
        expect(subject.success).to be_falsey
      end

      it 'records the migration version' do
        expect(subject.migration).to eq(migration)
      end

      it 'raises the exception' do
        expect { described_class.observe(migration, migration_block) }.to raise_error(/something went wrong/)
      end
    end

    context 'sequence of migrations with failures' do
      subject { described_class.new }

      let(:migration1) { double('migration1', call: nil) }
      let(:migration2) { double('migration2', call: nil) }

      it 'records observations for all migrations' do
        subject.observe('migration1', migration1)
        subject.observe('migration2', migration2) rescue nil

        expect(subject.observations.size).to eq(2)
      end
    end
  end
end

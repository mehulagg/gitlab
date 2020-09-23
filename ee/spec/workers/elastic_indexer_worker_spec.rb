# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ElasticIndexerWorker do
  subject { described_class.new }

  describe '#perform' do
    context 'indexing is enabled' do
      using RSpec::Parameterized::TableSyntax

      let(:project) { instance_double(Project, id: 1, es_id: 1) }

      before do
        stub_ee_application_setting(elasticsearch_indexing: true)
        expect(Project).to receive(:find).and_return(project)
      end

      where(:operation, :method) do
        'index'   |  'maintain_elasticsearch_create'
        'update'  |  'maintain_elasticsearch_update'
        'delete'  |  'maintain_elasticsearch_destroy'
      end

      with_them do
        it 'calls respective methods' do
          expect(project).to receive(method.to_sym)

          subject.perform(operation, 'Project', project.id, project.es_id)
        end
      end
    end

    context 'indexing is disabled' do
      before do
        stub_ee_application_setting(elasticsearch_indexing: false)
      end

      it 'returns true if ES disabled' do
        expect(Milestone).not_to receive(:find).with(1)

        expect(subject.perform('index', 'Milestone', 1, 1)).to be_truthy
      end
    end
  end
end

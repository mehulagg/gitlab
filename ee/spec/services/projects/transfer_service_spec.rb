# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::TransferService do
  include EE::GeoHelpers

  let_it_be(:user) { create(:user) }
  let(:group) { create(:group, :public) }
  let(:project) { create(:project, :repository, :public, :legacy_storage, namespace: user.namespace) }

  subject { described_class.new(project, user) }

  before do
    group.add_owner(user)
  end

  context 'when running on a primary node' do
    let_it_be(:primary) { create(:geo_node, :primary) }
    let_it_be(:secondary) { create(:geo_node) }

    it 'logs an event to the Geo event log' do
      stub_current_geo_node(primary)

      expect { subject.execute(group) }.to change(Geo::RepositoryRenamedEvent, :count).by(1)
    end
  end

  context 'audit events' do
    include_examples 'audit event logging' do
      let(:operation) { subject.execute(group) }
      let(:fail_condition!) do
        expect_next_instance_of(Project) do |instance|
          expect(instance).to receive(:has_container_registry_tags?).and_return(true)
        end
      end

      let(:attributes) do
        {
           author_id: user.id,
           entity_id: project.id,
           entity_type: 'Project',
           details: {
             change: 'namespace',
             from: project.old_path_with_namespace,
             to: project.full_path,
             author_name: user.name,
             target_id: project.id,
             target_type: 'Project',
             target_details: project.full_path
           }
         }
      end
    end
  end

  context 'missing epics applied to issues' do
    it 'delegates transfer to Epics::TransferService' do
      expect_next_instance_of(Epics::TransferService, user, project.group, project) do |epics_transfer_service|
        expect(epics_transfer_service).to receive(:execute).once.and_call_original
      end

      subject.execute(group)
    end
  end

  describe 'elasticsearch indexing', :elastic, :aggregate_failures do
    before do
      stub_ee_application_setting(elasticsearch_indexing: true)
    end

    context 'when visibility level changes' do
      let(:group) { create(:group, :private) }

      it 'reindexes the project and associated issues' do
        expect(Elastic::ProcessBookkeepingService).to receive(:track!).with(project)
        expect(ElasticAssociationIndexerWorker).to receive(:perform_async).with('Project', project.id, ['issues'])

        subject.execute(group)
      end
    end

    context 'when moving from a non-indexed namespace to an indexed namespace' do
      before do
        stub_ee_application_setting(elasticsearch_limit_indexing: true)

        create(:elasticsearch_indexed_namespace, namespace: group)
      end

      it 'invalidates the cache and reindexes the project and associated issues' do
        expect(Elastic::ProcessBookkeepingService).to receive(:track!).with(project)
        expect(ElasticAssociationIndexerWorker).to receive(:perform_async).with('Project', project.id, ['issues'])
        expect(::Gitlab::CurrentSettings).to receive(:invalidate_elasticsearch_indexes_cache_for_project!).with(project.id).and_call_original

        subject.execute(group)
      end
    end

    context 'when moving from an indexed namespace to a non-indexed namespace' do
      before do
        stub_ee_application_setting(elasticsearch_limit_indexing: true)

        create(:elasticsearch_indexed_namespace, namespace: project.namespace)
      end

      it 'invalidates the cache and does not index the project and associated issues' do
        expect(Elastic::ProcessBookkeepingService).not_to receive(:track!).with(project)
        expect(ElasticAssociationIndexerWorker).not_to receive(:perform_async).with('Project', project.id, ['issues'])
        expect(::Gitlab::CurrentSettings).to receive(:invalidate_elasticsearch_indexes_cache_for_project!).with(project.id).and_call_original

        subject.execute(group)
      end
    end

    context 'when both namespaces are indexed' do
      it 'does not invalidate the cache and reindexes the project only' do
        expect(Elastic::ProcessBookkeepingService).to receive(:track!).with(project)
        expect(ElasticAssociationIndexerWorker).not_to receive(:perform_async)
        expect(::Gitlab::CurrentSettings).not_to receive(:invalidate_elasticsearch_indexes_cache_for_project!)

        subject.execute(group)
      end
    end
  end
end

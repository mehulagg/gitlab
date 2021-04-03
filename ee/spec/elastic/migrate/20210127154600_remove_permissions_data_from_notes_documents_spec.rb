# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20210127154600_remove_permissions_data_from_notes_documents.rb')

RSpec.describe RemovePermissionsDataFromNotesDocuments, :elastic, :sidekiq_inline do
  let(:version) { 20210127154600 }
  let(:migration) { described_class.new(version) }
  let(:helper) { Gitlab::Elastic::Helper.new }

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
    allow(migration).to receive(:helper).and_return(helper)
    set_elasticsearch_migration_to :remove_permissions_data_from_notes_documents, including: false
  end

  describe 'migration_options' do
    it 'has migration options set', :aggregate_failures do
      expect(migration.batched?).to be_truthy
      expect(migration.throttle_delay).to eq(1.minute)
    end
  end

  describe '#migrate' do
    let!(:note_on_commit) { create(:note_on_commit) }
    let!(:note_on_issue) { create(:note_on_issue) }
    let!(:note_on_merge_request) { create(:note_on_merge_request) }
    let!(:note_on_snippet) { create(:note_on_project_snippet) }

    before do
      ensure_elasticsearch_index!
    end

    context 'when migration is completed' do
      before do
        remove_permission_data_for_notes([note_on_commit, note_on_issue, note_on_merge_request, note_on_snippet])
      end

      it 'does not queue documents for indexing', :aggregate_failures do
        expect(migration.completed?).to be_truthy
        expect(::Elastic::ProcessBookkeepingService).not_to receive(:track!)

        migration.migrate
      end
    end

    context 'migration process' do
      before do
        add_permission_data_for_notes([note_on_commit, note_on_issue, note_on_merge_request, note_on_snippet])

        # migrations are completed by default in test environments
        # required to prevent the `as_indexed_json` method from populating the permissions fields
        set_elasticsearch_migration_to version, including: false
      end

      it 'queues documents for indexing' do
        # track calls are batched in groups of 100
        expect(::Elastic::ProcessBookkeepingService).to receive(:track!).once do |*tracked_refs|
          expect(tracked_refs.count).to eq(4)
        end

        migration.migrate
      end

      it 'only queues documents for indexing that contain permission data', :aggregate_failures do
        remove_permission_data_for_notes([note_on_issue, note_on_snippet, note_on_merge_request])

        expected = [Gitlab::Elastic::DocumentReference.new(Note, note_on_commit.id, note_on_commit.es_id, note_on_commit.es_parent)]
        expect(::Elastic::ProcessBookkeepingService).to receive(:track!).with(*expected).once

        migration.migrate
      end

      it 'processes in batches until completed' do
        stub_const("#{described_class}::QUERY_BATCH_SIZE", 2)
        stub_const("#{described_class}::UPDATE_BATCH_SIZE", 1)

        allow(::Elastic::ProcessBookkeepingService).to receive(:track!).and_call_original

        migration.migrate

        expect(::Elastic::ProcessBookkeepingService).to have_received(:track!).exactly(2).times

        ensure_elasticsearch_index!
        migration.migrate

        expect(::Elastic::ProcessBookkeepingService).to have_received(:track!).exactly(4).times

        ensure_elasticsearch_index!
        migration.migrate

        # The migration should have already finished so there are no more items to process
        expect(::Elastic::ProcessBookkeepingService).to have_received(:track!).exactly(4).times
        expect(migration).to be_completed
      end
    end
  end

  describe '#completed?' do
    let!(:note_on_commit) { create(:note_on_commit) }

    before do
      ensure_elasticsearch_index!
    end

    subject { migration.completed? }

    context 'when no documents have permissions data' do
      before do
        remove_permission_data_for_notes([note_on_commit])
      end

      it { is_expected.to be_truthy }
    end

    context 'when documents have permissions data' do
      before do
        add_permission_data_for_notes([note_on_commit])
      end

      it { is_expected.to be_falsey }
    end

    it 'refreshes the index' do
      expect(helper).to receive(:refresh_index)

      subject
    end
  end

  private

  def add_permission_data_for_notes(notes)
    script =  {
      source: "ctx._source['visibility_level'] = params.visibility_level; ctx._source['issues_access_level'] = params.visibility_level; ctx._source['merge_requests_access_level'] = params.visibility_level; ctx._source['snippets_access_level'] = params.visibility_level; ctx._source['repository_access_level'] = params.visibility_level;",
      lang: "painless",
      params: {
        visibility_level: Gitlab::VisibilityLevel::PRIVATE
      }
    }

    update_by_query(notes, script)
  end

  def remove_permission_data_for_notes(notes)
    script =  {
      source: "ctx._source.remove('visibility_level'); ctx._source.remove('repository_access_level'); ctx._source.remove('snippets_access_level'); ctx._source.remove('merge_requests_access_level'); ctx._source.remove('issues_access_level');"
    }

    update_by_query(notes, script)
  end

  def update_by_query(notes, script)
    note_ids = notes.map { |i| i.id }

    client = Note.__elasticsearch__.client
    client.update_by_query({
                             index: Note.__elasticsearch__.index_name,
                             wait_for_completion: true, # run synchronously
                             refresh: true, # make operation visible to search
                             body: {
                               script: script,
                               query: {
                                 bool: {
                                   must: [
                                     {
                                       terms: {
                                         id: note_ids
                                       }
                                     },
                                     {
                                       term: {
                                         type: {
                                           value: 'note'
                                         }
                                       }
                                     }
                                   ]
                                 }
                               }
                             }
                           })
  end
end

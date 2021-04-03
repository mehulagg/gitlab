# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20210128163600_add_permissions_data_to_notes_documents.rb')

RSpec.describe AddPermissionsDataToNotesDocuments, :elastic, :sidekiq_inline do
  let(:version) { 20210128163600 }
  let(:migration) { described_class.new(version) }

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
    set_elasticsearch_migration_to :add_permissions_data_to_notes_documents, including: false
  end

  describe 'migration_options' do
    it 'has migration options set', :aggregate_failures do
      expect(migration.batched?).to be_truthy
      expect(migration.throttle_delay).to eq(3.minutes)
    end
  end

  describe '#migrate' do
    let(:notes) { [note_on_commit, note_on_issue, note_on_merge_request, note_on_snippet] }
    let!(:note_on_commit) { create(:note_on_commit) }
    let!(:note_on_issue) { create(:note_on_issue) }
    let!(:note_on_merge_request) { create(:note_on_merge_request) }
    let!(:note_on_snippet) { create(:note_on_project_snippet) }

    before do
      ensure_elasticsearch_index!
    end

    context 'when migration is completed' do
      it 'does not queue documents for indexing' do
        expect(migration.completed?).to be_truthy
        expect(::Elastic::ProcessInitialBookkeepingService).not_to receive(:track!)

        migration.migrate
      end
    end

    context 'migration process' do
      before do
        remove_permission_data_for_notes(notes)
      end

      it 'queues documents for indexing' do
        expect(::Elastic::ProcessInitialBookkeepingService).to receive(:track!).once do |*tracked_refs|
          expect(tracked_refs.count).to eq(4)
        end

        migration.migrate
      end

      it 'only queues documents for indexing that are missing permission data', :aggregate_failures do
        add_permission_data_for_notes([note_on_issue, note_on_snippet, note_on_merge_request])

        expected = [Gitlab::Elastic::DocumentReference.new(Note, note_on_commit.id, note_on_commit.es_id, note_on_commit.es_parent)]
        expect(::Elastic::ProcessInitialBookkeepingService).to receive(:track!).with(*expected).once

        migration.migrate
      end

      it 'processes in batches until completed', :aggregate_failures do
        stub_const("#{described_class}::QUERY_BATCH_SIZE", 2)
        stub_const("#{described_class}::UPDATE_BATCH_SIZE", 1)

        allow(::Elastic::ProcessInitialBookkeepingService).to receive(:track!).and_call_original

        migration.migrate

        expect(::Elastic::ProcessInitialBookkeepingService).to have_received(:track!).exactly(2).times

        ensure_elasticsearch_index!
        migration.migrate

        expect(::Elastic::ProcessInitialBookkeepingService).to have_received(:track!).exactly(4).times

        ensure_elasticsearch_index!
        migration.migrate

        # The migration should have already finished so there are no more items to process
        expect(::Elastic::ProcessInitialBookkeepingService).to have_received(:track!).exactly(4).times
        expect(migration).to be_completed
      end
    end
  end

  describe '#completed?' do
    using RSpec::Parameterized::TableSyntax

    let(:helper) { Gitlab::Elastic::Helper.new }

    subject { migration.completed? }

    before do
      allow(migration).to receive(:helper).and_return(helper)
    end

    it 'refreshes the index' do
      expect(helper).to receive(:refresh_index)

      subject
    end

    # Only affected note types are issue, commit, merge requests, project snippets and completed? should return
    # false if documents are missing data. The completed? method will be true for all other types
    where(:note_type, :expected_result) do
      :diff_note_on_commit                    | false
      :diff_note_on_design                    | true
      :diff_note_on_merge_request             | false
      :discussion_note_on_commit              | false
      :discussion_note_on_issue               | false
      :discussion_note_on_merge_request       | false
      :discussion_note_on_personal_snippet    | true
      :discussion_note_on_project_snippet     | false
      :discussion_note_on_vulnerability       | true
      :legacy_diff_note_on_commit             | false
      :legacy_diff_note_on_merge_request      | false
      :note_on_alert                          | true
      :note_on_commit                         | false
      :note_on_design                         | true
      :note_on_epic                           | true
      :note_on_issue                          | false
      :note_on_merge_request                  | false
      :note_on_personal_snippet               | true
      :note_on_project_snippet                | false
      :note_on_vulnerability                  | true
    end

    with_them do
      let!(:note) { create(note_type) } # rubocop:disable Rails/SaveBang

      context 'when documents are missing permissions data' do
        before do
          ensure_elasticsearch_index!
          remove_permission_data_for_notes([note])
        end

        it { is_expected.to eq(expected_result) }
      end

      context 'when no documents are missing permissions data' do
        before do
          ensure_elasticsearch_index!
        end

        it { is_expected.to be_truthy }
      end
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
    note_ids = notes.map(&:id)

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

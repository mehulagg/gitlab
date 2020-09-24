# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Search::ProjectService do
  include SearchResultHelpers
  include ProjectHelpers
  using RSpec::Parameterized::TableSyntax

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
  end

  it_behaves_like 'EE search service shared examples', ::Gitlab::ProjectSearchResults, ::Gitlab::Elastic::ProjectSearchResults do
    let(:user) { scope.owner }
    let(:scope) { create(:project) }
    let(:service) { described_class.new(scope, user, params) }
  end

  context 'code search' do
    let(:user) { scope.owner }
    let(:scope) { create(:project) }
    let(:service) { described_class.new(scope, user, params) }
    let(:params) { { search: '*' } }

    describe '#execute' do
      subject { service.execute }

      it 'returns ordinary results when searching non-default branch' do
        expect(service).to receive(:default_branch?).and_return(false)

        is_expected.to be_a(::Gitlab::ProjectSearchResults)
      end
    end
  end

  context 'visibility', :elastic, :sidekiq_inline do
    include_context 'ProjectPolicyTable context'

    let_it_be(:group) { create(:group) }
    let!(:project) { create(:project, project_level, namespace: group) }
    let!(:project2) { create(:project, project_level) }
    let(:user) { create_user_from_membership(project, membership) }

    context 'merge request' do
      let!(:merge_request) { create :merge_request, target_project: project, source_project: project }
      let!(:merge_request2) { create :merge_request, target_project: project2, source_project: project2, title: merge_request.title }
      let!(:note) { create :note, project: project, noteable: merge_request }
      let!(:note2) { create :note, project: project2, noteable: merge_request2, note: note.note }

      where(:project_level, :feature_access_level, :membership, :expected_count) do
        permission_table_for_reporter_feature_access
      end

      with_them do
        it "respects visibility" do
          [project, project2].each do |project|
            update_feature_access_level(project, feature_access_level)
          end
          ensure_elasticsearch_index!

          expect_search_results(user, 'merge_requests', expected_count: expected_count) do |user|
            described_class.new(project, user, search: merge_request.title).execute
          end

          expect_search_results(user, 'notes', expected_count: expected_count) do |user|
            described_class.new(project, user, search: note.note).execute
          end
        end
      end
    end

    context 'code' do
      let!(:project) { create(:project, project_level, :repository, namespace: group ) }
      let!(:project2) { create(:project, project_level, :repository) }
      let!(:note) { create :note_on_commit, project: project }
      let!(:note2) { create :note_on_commit, project: project2, note: note.note }

      where(:project_level, :feature_access_level, :membership, :expected_count) do
        permission_table_for_guest_feature_access_and_non_private_project_only
      end

      with_them do
        it "respects visibility" do
          [project, project2].each do |project|
            update_feature_access_level(project, feature_access_level)
            ElasticCommitIndexerWorker.new.perform(project.id)
          end
          ensure_elasticsearch_index!

          expect_search_results(user, 'commits', expected_count: expected_count) do |user|
            described_class.new(project, user, search: 'initial').execute
          end

          expect_search_results(user, 'blobs', expected_count: expected_count) do |user|
            described_class.new(project, user, search: '.gitmodules').execute
          end

          expect_search_results(user, 'notes', expected_count: expected_count) do |user|
            described_class.new(project, user, search: note.note).execute
          end
        end
      end
    end

    context 'issue' do
      let!(:issue) { create :issue, project: project }
      let!(:issue2) { create :issue, project: project2, title: issue.title }
      let!(:note) { create :note, project: project, noteable: issue }
      let!(:note2) { create :note, project: project2, noteable: issue2, note: note.note }

      where(:project_level, :feature_access_level, :membership, :expected_count) do
        permission_table_for_guest_feature_access
      end

      with_them do
        it "respects visibility" do
          [project, project2].each do |project|
            update_feature_access_level(project, feature_access_level)
          end
          ensure_elasticsearch_index!

          expect_search_results(user, 'issues', expected_count: expected_count) do |user|
            described_class.new(project, user, search: issue.title).execute
          end

          expect_search_results(user, 'notes', expected_count: expected_count) do |user|
            described_class.new(project, user, search: note.note).execute
          end
        end
      end
    end

    context 'wiki' do
      let!(:project) { create(:project, project_level, :wiki_repo) }

      where(:project_level, :feature_access_level, :membership, :expected_count) do
        permission_table_for_guest_feature_access
      end

      with_them do
        it "respects visibility" do
          project.wiki.create_page('test.md', '# term')
          project.wiki.index_wiki_blobs
          update_feature_access_level(project, feature_access_level)
          ensure_elasticsearch_index!

          expect_search_results(user, 'wiki_blobs', expected_count: expected_count) do |user|
            described_class.new(project, user, search: 'term').execute
          end
        end
      end
    end

    context 'milestone' do
      let!(:milestone) { create :milestone, project: project }

      where(:project_level, :issues_access_level, :merge_requests_access_level, :membership, :expected_count) do
        permission_table_for_milestone_access
      end

      with_them do
        it "respects visibility" do
          project.update!(
            'issues_access_level' => issues_access_level,
            'merge_requests_access_level' => merge_requests_access_level
          )
          ensure_elasticsearch_index!

          expect_search_results(user, 'milestones', expected_count: expected_count) do |user|
            described_class.new(project, user, search: milestone.title).execute
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Search::GlobalService do
  include SearchResultHelpers
  include ProjectHelpers
  using RSpec::Parameterized::TableSyntax

  let(:user) { create(:user) }

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
  end

  it_behaves_like 'EE search service shared examples', ::Gitlab::SearchResults, ::Gitlab::Elastic::SearchResults do
    let(:scope) { nil }
    let(:service) { described_class.new(user, params) }
  end

  context 'visibility', :elastic, :sidekiq_inline do
    include_context 'ProjectPolicyTable context'

    let_it_be(:group) { create(:group) }
    let(:project) { create(:project, project_level, namespace: group) }
    let(:user) { create_user_from_membership(project, membership) }

    context 'merge request' do
      let!(:merge_request) { create :merge_request, target_project: project, source_project: project }
      let!(:note) { create :note, project: project, noteable: merge_request }

      where(:project_level, :feature_access_level, :membership, :admin_mode, :expected_count) do
        permission_table_for_reporter_feature_access
      end

      with_them do
        it "respects visibility" do
          enable_admin_mode!(user) if admin_mode
          update_feature_access_level(project, feature_access_level)
          ensure_elasticsearch_index!

          expect_search_results(user, 'merge_requests', expected_count: expected_count) do |user|
            described_class.new(user, search: merge_request.title).execute
          end

          expect_search_results(user, 'notes', expected_count: expected_count) do |user|
            described_class.new(user, search: note.note).execute
          end
        end
      end
    end

    context 'code' do
      let!(:project) { create(:project, project_level, :repository, namespace: group ) }
      let!(:note) { create :note_on_commit, project: project }

      where(:project_level, :feature_access_level, :membership, :admin_mode, :expected_count) do
        permission_table_for_guest_feature_access_and_non_private_project_only
      end

      with_them do
        it "respects visibility" do
          enable_admin_mode!(user) if admin_mode
          update_feature_access_level(project, feature_access_level)
          ElasticCommitIndexerWorker.new.perform(project.id)
          ensure_elasticsearch_index!

          expect_search_results(user, 'commits', expected_count: expected_count) do |user|
            described_class.new(user, search: 'initial').execute
          end

          expect_search_results(user, 'blobs', expected_count: expected_count) do |user|
            described_class.new(user, search: '.gitmodules').execute
          end

          expect_search_results(user, 'notes', expected_count: expected_count) do |user|
            described_class.new(user, search: note.note).execute
          end
        end
      end
    end

    context 'issue' do
      let(:scope) { 'issues' }

      context 'visibility' do
        let!(:issue) { create :issue, project: project }
        let!(:note) { create :note, project: project, noteable: issue }

        where(:project_level, :feature_access_level, :membership, :admin_mode, :expected_count) do
          permission_table_for_guest_feature_access
        end

        with_them do
          it "respects visibility" do
            enable_admin_mode!(user) if admin_mode
            update_feature_access_level(project, feature_access_level)
            ensure_elasticsearch_index!

            expect_search_results(user, 'issues', expected_count: expected_count) do |user|
              described_class.new(user, search: issue.title).execute
            end

            expect_search_results(user, 'notes', expected_count: expected_count) do |user|
              described_class.new(user, search: note.note).execute
            end
          end
        end
      end

      # Since newly created indices automatically have all migrations as
      # finished we need a test to verify the old style searches work for
      # instances which haven't finished the migration yet
      context 'when add_new_data_to_issues_documents migration is not finished' do
        before do
          allow(Elastic::DataMigrationService).to receive(:migration_has_finished?).and_call_original
          allow(Elastic::DataMigrationService).to receive(:migration_has_finished?)
            .with(:add_new_data_to_issues_documents)
            .and_return(false)
          allow(Elastic::DataMigrationService).to receive(:migration_has_finished?)
            .with(:migrate_issues_to_separate_index)
            .and_return(false)
        end

        # issue cannot be defined prior to the migration mocks because it
        # will cause the incorrect value to be passed to `use_separate_indices` when creating
        # the proxy
        let!(:issue) { create(:issue, project: project) }

        where(:project_level, :feature_access_level, :membership, :admin_mode, :expected_count) do
          permission_table_for_guest_feature_access
        end

        with_them do
          it "respects visibility" do
            enable_admin_mode!(user) if admin_mode
            update_feature_access_level(project, feature_access_level)
            ensure_elasticsearch_index!

            expect_search_results(user, 'issues', expected_count: expected_count) do |user|
              described_class.new(user, search: issue.title).execute
            end
          end
        end
      end

      context 'sort by created_at' do
        let!(:project) { create(:project, :public) }
        let!(:old_result) { create(:issue, project: project, title: 'sorted old', created_at: 1.month.ago) }
        let!(:new_result) { create(:issue, project: project, title: 'sorted recent', created_at: 1.day.ago) }
        let!(:very_old_result) { create(:issue, project: project, title: 'sorted very old', created_at: 1.year.ago) }

        before do
          ensure_elasticsearch_index!
        end

        include_examples 'search results sorted' do
          let(:results) { described_class.new(nil, search: 'sorted', sort: sort).execute }
        end
      end

      context 'using joins for global permission checks' do
        let(:results) { described_class.new(nil, search: '*').execute.objects('issues') }
        let(:es_host) { Gitlab::CurrentSettings.elasticsearch_url[0] }
        let(:search_url) { Addressable::Template.new("#{es_host}/{index}/doc/_search{?params*}") }

        before do
          allow(Elastic::DataMigrationService).to receive(:migration_has_finished?).and_call_original
          allow(Elastic::DataMigrationService).to receive(:migration_has_finished?)
            .with(:migrate_issues_to_separate_index)
            .and_return(false)

          ensure_elasticsearch_index!
        end

        context 'when add_new_data_to_issues_documents migration is finished' do
          before do
            allow(Elastic::DataMigrationService).to receive(:migration_has_finished?)
              .with(:add_new_data_to_issues_documents)
              .and_return(true)
          end

          it 'does not use joins to apply permissions' do
            request = a_request(:get, search_url).with do |req|
              expect(req.body).not_to include("has_parent")
            end

            results

            expect(request).to have_been_made
          end
        end

        context 'when add_new_data_to_issues_documents migration is not finished' do
          before do
            allow(Elastic::DataMigrationService).to receive(:migration_has_finished?)
              .with(:add_new_data_to_issues_documents)
              .and_return(false)
          end

          it 'uses joins to apply permissions' do
            request = a_request(:get, search_url).with do |req|
              expect(req.body).to include("has_parent")
            end

            results

            expect(request).to have_been_made
          end
        end
      end
    end

    context 'merge_request' do
      let(:scope) { 'merge_requests' }

      context 'sort by created_at' do
        let!(:project) { create(:project, :public) }
        let!(:old_result) { create(:merge_request, :opened, source_project: project, source_branch: 'old-1', title: 'sorted old', created_at: 1.month.ago) }
        let!(:new_result) { create(:merge_request, :opened, source_project: project, source_branch: 'new-1', title: 'sorted recent', created_at: 1.day.ago) }
        let!(:very_old_result) { create(:merge_request, :opened, source_project: project, source_branch: 'very-old-1', title: 'sorted very old', created_at: 1.year.ago) }

        before do
          ensure_elasticsearch_index!
        end

        include_examples 'search results sorted' do
          let(:results) { described_class.new(nil, search: 'sorted', sort: sort).execute }
        end
      end
    end

    context 'wiki' do
      let!(:project) { create(:project, project_level, :wiki_repo) }

      where(:project_level, :feature_access_level, :membership, :admin_mode, :expected_count) do
        permission_table_for_guest_feature_access
      end

      with_them do
        it "respects visibility" do
          enable_admin_mode!(user) if admin_mode
          project.wiki.create_page('test.md', '# term')
          project.wiki.index_wiki_blobs
          update_feature_access_level(project, feature_access_level)
          ensure_elasticsearch_index!

          expect_search_results(user, 'wiki_blobs', expected_count: expected_count) do |user|
            described_class.new(user, search: 'term').execute
          end
        end
      end
    end

    context 'milestone' do
      let!(:milestone) { create :milestone, project: project }

      where(:project_level, :issues_access_level, :merge_requests_access_level, :membership, :admin_mode, :expected_count) do
        permission_table_for_milestone_access
      end

      with_them do
        it "respects visibility" do
          enable_admin_mode!(user) if admin_mode
          project.update!(
            'issues_access_level' => issues_access_level,
            'merge_requests_access_level' => merge_requests_access_level
          )
          ensure_elasticsearch_index!

          expect_search_results(user, 'milestones', expected_count: expected_count) do |user|
            described_class.new(user, search: milestone.title).execute
          end
        end
      end
    end

    context 'project' do
      where(:project_level, :membership, :expected_count) do
        permission_table_for_project_access
      end

      with_them do
        it "respects visibility" do
          ElasticCommitIndexerWorker.new.perform(project.id)
          ensure_elasticsearch_index!

          expected_objects = expected_count == 1 ? [project] : []

          expect_search_results(
            user,
            'projects',
            expected_count: expected_count,
            expected_objects: expected_objects
          ) do |user|
            described_class.new(user, search: project.name).execute
          end
        end
      end
    end
  end

  describe '#allowed_scopes' do
    context 'when ES is used' do
      it 'includes ES-specific scopes' do
        expect(described_class.new(user, {}).allowed_scopes).to include('commits')
      end
    end

    context 'when elasticearch_search is disabled' do
      before do
        stub_ee_application_setting(elasticsearch_search: false)
      end

      it 'does not include ES-specific scopes' do
        expect(described_class.new(user, {}).allowed_scopes).not_to include('commits')
      end
    end

    context 'when elasticsearch_limit_indexing is enabled' do
      before do
        stub_ee_application_setting(elasticsearch_limit_indexing: true)
      end

      context 'when advanced_global_search_for_limited_indexing feature flag is disabled' do
        before do
          stub_feature_flags(advanced_global_search_for_limited_indexing: false)
        end

        it 'does not include ES-specific scopes' do
          expect(described_class.new(user, {}).allowed_scopes).not_to include('commits')
        end
      end

      context 'when advanced_global_search_for_limited_indexing feature flag is enabled' do
        it 'includes ES-specific scopes' do
          expect(described_class.new(user, {}).allowed_scopes).to include('commits')
        end
      end
    end
  end

  describe '#elastic_projects' do
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, namespace: group) }
    let_it_be(:another_project) { create(:project) }
    let_it_be(:non_admin_user) { create_user_from_membership(project, :developer) }
    let_it_be(:admin) { create(:admin) }

    let(:service) { described_class.new(user, {}) }
    let(:elastic_projects) { service.elastic_projects }

    context 'when the user is an admin' do
      let(:user) { admin }

      context 'when admin mode is enabled', :enable_admin_mode do
        it 'returns :any' do
          expect(elastic_projects).to eq(:any)
        end
      end

      context 'when admin mode is disabled' do
        it 'returns empty array' do
          expect(elastic_projects).to eq([])
        end
      end
    end

    context 'when the user is not an admin' do
      let(:user) { non_admin_user }

      it 'returns the projects the user has access to' do
        expect(elastic_projects).to eq([project.id])
      end
    end

    context 'when there is no user' do
      let(:user) { nil }

      it 'returns empty array' do
        expect(elastic_projects).to eq([])
      end
    end
  end

  context 'confidential notes' do
    let(:project) { create(:project, :public) }

    context 'with notes on issues' do
      it_behaves_like 'search notes shared examples' do
        let(:noteable) { create :issue, project: project }
      end
    end

    context 'with notes on merge requests' do
      it_behaves_like 'search notes shared examples' do
        let(:noteable) { create :merge_request, target_project: project, source_project: project }
      end
    end

    context 'with notes on commits' do
      it_behaves_like 'search notes shared examples' do
        let(:noteable) { create(:commit, project: project) }
      end
    end
  end
end

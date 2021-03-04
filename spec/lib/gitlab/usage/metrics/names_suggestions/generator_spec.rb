# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::NamesSuggestions::Generator do
  describe '#generate' do
    shared_examples 'name suggestion' do
      it 'return correct name' do
        expect(described_class.generate(key_path)).to eq name_suggestion
      end
    end

    context 'for count metrics' do
      let(:key_path) { 'counts.boards' }
      let(:name_suggestion) { 'count_boards' }

      it_behaves_like 'name suggestion'
    end

    context 'for count distinct metrics' do
      let(:key_path) { 'counts.issues_using_zoom_quick_actions' }
      let(:name_suggestion) { 'count_distinct_issue_id_from_zoom_meetings' }

      it_behaves_like 'name suggestion'
    end

    context 'for sum metrics' do
      let(:key_path) { 'counts.jira_imports_total_imported_issues_count' }
      let(:name_suggestion) { "add_count_<adjective describing: '(snippets.type = 'PersonalSnippet')'>_snippets_and_count_<adjective describing: '(snippets.type = 'ProjectSnippet')'>_snippets" }

      it_behaves_like 'name suggestion'
    end

    context 'for add metrics' do
      let(:key_path) { 'counts.snippets' }
      let(:name_suggestion) { 'add_count_snippets_and_count_snippets' }

      it_behaves_like 'name suggestion'
    end

    context 'for redis metrics' do
      let(:key_path) { 'analytics_unique_visits.analytics_unique_visits_for_any_target' }
      let(:name_suggestion) { 'names_suggestions_for_redis_counters_are_not_supported_yet' }

      it_behaves_like 'name suggestion'
    end
  end
end

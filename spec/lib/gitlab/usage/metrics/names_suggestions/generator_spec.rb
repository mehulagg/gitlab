# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metrics::NamesSuggestions::Generator do
  describe '#generate' do
    context 'for count metrics' do
      it 'return correct name' do
        expect(described_class.generate('counts.boards')).to eq 'count_boards'
      end
    end

    context 'for count distinct metrics' do
      it 'return correct name' do
        expect(described_class.generate('counts.issues_using_zoom_quick_actions')).to eq 'count_distinct_issue_id_from_zoom_meetings'
      end
    end

    context 'for sum metrics' do
      it 'return correct name' do
        expect(described_class.generate('counts.jira_imports_total_imported_issues_count')).to eq 'sum_imported_issues_count_from_jira_imports'
      end
    end

    context 'for add metrics' do
      it 'return correct name' do
        expect(described_class.generate('counts.snippets')).to eq 'add_count_snippets_and_count_snippets'
      end
    end

    context 'for redis metrics' do
      it 'return correct name' do
        expect(described_class.generate('analytics_unique_visits.analytics_unique_visits_for_any_target')).to eq 'names_suggestions_for_redis_counters_are_not_supported_yet'
      end
    end
  end
end

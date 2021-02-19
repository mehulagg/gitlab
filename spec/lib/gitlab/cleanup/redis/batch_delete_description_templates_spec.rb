# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Cleanup::Redis::BatchDeleteDescriptionTemplates, :clean_gitlab_redis_cache do
  subject { described_class.new(project_ids) }

  describe 'execute' do
    context 'when no project_ids are passed' do
      context 'with nil project_ids' do
        let(:project_ids) { nil }

        it 'builds pattern to remove all issue and merge request templates keys' do
          expect(subject.patterns.count).to eq(2)
          expect(subject.patterns).to match_array(%W[
            #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:issue_template_names_by_category:*
            #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:merge_request_template_names_by_category:*
          ])
        end
      end

      context 'with empty array project_ids' do
        let(:project_ids) { [] }

        it 'builds pattern to remove all issue and merge request templates keys' do
          expect(subject.patterns.count).to eq(2)
          expect(subject.patterns).to match_array(%W[
            #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:issue_template_names_by_category:*
            #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:merge_request_template_names_by_category:*
          ])
        end
      end
    end

    context 'with project_ids' do
      let_it_be(:project1) { create(:project, :repository) }
      let_it_be(:project2) { create(:project, :repository) }

      context 'with non existent project id' do
        let(:project_ids) { [non_existing_record_id] }

        it 'no patterns are built' do
          expect(subject.patterns.count).to eq(0)
        end
      end

      context 'with one project_id' do
        let(:project_ids) { [project1.id] }

        it 'builds patterns for the project' do
          repo_cache = Gitlab::RepositoryCache.new(project1.repository)

          expect(subject.patterns.count).to eq(2)
          expect(subject.patterns).to match_array(%W[
            #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:#{repo_cache&.cache_key(:issue_template_names_by_category)}
            #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:#{repo_cache&.cache_key(:merge_request_template_names_by_category)}
          ])
        end
      end

      context 'with many project_ids' do
        let(:project_ids) { [project1.id, project2.id] }

        it 'builds patterns for the project' do
          repo_cache1 = Gitlab::RepositoryCache.new(project1.repository)
          repo_cache2 = Gitlab::RepositoryCache.new(project2.repository)

          expect(subject.patterns.count).to eq(4)

          expect(subject.patterns).to match_array(%W[
            #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:#{repo_cache1&.cache_key(:issue_template_names_by_category)}
            #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:#{repo_cache1&.cache_key(:merge_request_template_names_by_category)}
            #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:#{repo_cache2&.cache_key(:issue_template_names_by_category)}
            #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:#{repo_cache2&.cache_key(:merge_request_template_names_by_category)}
          ])
        end
      end
    end
  end
end

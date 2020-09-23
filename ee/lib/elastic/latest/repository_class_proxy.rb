# frozen_string_literal: true

module Elastic
  module Latest
    class RepositoryClassProxy < ApplicationClassProxy
      include GitClassProxy

      def es_type
        'blob'
      end

      # @return [Kaminari::PaginatableArray]
      def find_commits_by_message_with_elastic(query, page: 1, per_page: 20, options: {}, preload_method: nil)
        elastic_search_and_wrap(query, type: 'commit', page: page, per: per_page, options: options, preload_method: preload_method) do |result, project|
          raw_commit = Gitlab::Git::Commit.new(
            project.repository.raw,
            prepare_commit(result['_source']['commit']),
            lazy_load_parents: true
          )
          Commit.new(raw_commit, project)
        end
      end

      private

      def prepare_commit(raw_commit_hash)
        {
          id: raw_commit_hash['sha'],
          message: raw_commit_hash['message'],
          parent_ids: nil,
          author_name: raw_commit_hash['author']['name'],
          author_email: raw_commit_hash['author']['email'],
          authored_date: Time.parse(raw_commit_hash['author']['time']).utc,
          committer_name: raw_commit_hash['committer']['name'],
          committer_email: raw_commit_hash['committer']['email'],
          committed_date: Time.parse(raw_commit_hash['committer']['time']).utc
        }
      end
    end
  end
end

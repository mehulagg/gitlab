# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module BackfillVersionDataFromGitaly
        extend ::Gitlab::Utils::Override

        class Version < ActiveRecord::Base
          self.table_name = 'design_management_versions'
          self.inheritance_column = :_type_disabled

          # The `sha` of a version record must be deserialized from binary
          # in order to convert it to a `sha` String that can be used to fetch
          # a corresponding Commit from Git.
          def sha
            value = super

            value.unpack1('H*')
          end

          scope :backfillable_for_issue, -> (issue_id) do
            where(author_id: nil).or(where(created_at: nil))
            .where(issue_id: issue_id)
          end
        end

        class Issue < ActiveRecord::Base
          self.table_name = 'issues'
          self.inheritance_column = :_type_disabled
        end

        override :perform
        def perform(issue_id)
          issue = Issue.find_by_id(issue_id)
          return unless issue

          # We need a full Project instance in order to initialize a
          # Repository instance that can perform Gitaly calls.
          project = ::Project.find_by_id(issue.project_id)
          return if project.nil? || project.pending_delete?

          # We need a full Repository instance to perform Gitaly calls.
          repository = ::DesignManagement::Repository.new(project)
          versions = Version.backfillable_for_issue(issue_id)
          commits = commits_for_versions(versions, repository)

          ActiveRecord::Base.transaction do
            versions.each do |version|
              commit = commits[version.sha]

              unless commit.nil?
                version.update_columns(created_at: commit.created_at, author_id: commit.author&.id)
              end
            end
          end
        end

        private

        # Performs a Gitaly request to fetch the corresponding Commit data
        # for the given versions.
        #
        # Returns Commits as a Hash of { sha => Commit }
        def commits_for_versions(versions, repository)
          shas = versions.map(&:sha)

          commits = repository.commits_by(oids: shas)
          # Batch load the commit authors so the `User` records are fetched
          # all at once the first time we call `commit.author.id`.
          commits.each(&:lazy_author)

          commits.each_with_object({}) do |commit, hash|
            hash[commit.id] = commit
          end
        end
      end
    end
  end
end

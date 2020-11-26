# frozen_string_literal: true

module Gitlab
  module GithubImport
    module Importer
      class PullRequestReviewImporter
        REVIEW_TYPE_MAP = {
          'APPROVED' => 'Approved by',
          'COMMENTED' => 'Commented by',
          'CHANGES_REQUESTED' => 'Changes requested by'
        }.freeze

        def initialize(review, project, client)
          @review = review
          @project = project
          @client = client
        end

        def execute
          user_finder = GithubImport::UserFinder.new(project, client)
          gitlab_user_id = user_finder.user_id_for(review.author)

          if gitlab_user_id
            add_review_note(gitlab_user_id)
          else
            add_complementary_review_note(project.creator_id)
          end

          if review.review_type == 'APPROVED'
            merge_request.approvals.create!(
              user: gitlab_user,
              created_at: review.created_at
            )
          end
        end

        private

        attr_reader :review, :project, :client

        def merge_request
          @merge_request ||= project.merge_requests.find(review.merge_request_id)
        end

        def add_review_note(author_id)
          add_note(author_id, review.note)
        end

        def add_complementary_review_note(author_id)
          note = "%{note}\n\n*%{type} %{author}*" % {
            note: review.note,
            type: REVIEW_TYPE_MAP[review.review_type],
            author: review.author.login
          }

          add_note(author_id, note)
        end

        def add_note(author_id, note)
          merge_request.notes.create(
            note: note,
            author_id: project.creator_id,
            project: project
          )
        end
      end
    end
  end
end

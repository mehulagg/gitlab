# frozen_string_literal: true

module Gitlab
  module GithubImport
    module Representation
      class PullRequestReview
        include ToHash
        include ExposeAttribute

        attr_reader :attributes

        expose_attribute :author, :note, :review_type, :created_at, :github_id, :merge_request_id

        def self.from_api_response(review)
          user = Representation::User.from_api_response(review.user) if review.user

          hash = {
            merge_request_id: review.merge_request_id,
            author: user,
            note: review.body,
            review_type: review.state,
            created_at: review.submitted_at,
            github_id: review.id
          }

          new(hash)
        end

        # Builds a new note using a Hash that was built from a JSON payload.
        def self.from_json_hash(raw_hash)
          hash = Representation.symbolize_hash(raw_hash)

          hash[:author] &&= Representation::User.from_json_hash(hash[:author])

          new(hash)
        end

        # attributes - A Hash containing the raw note details. The keys of this
        #              Hash must be Symbols.
        def initialize(attributes)
          @attributes = attributes
        end
      end
    end
  end
end

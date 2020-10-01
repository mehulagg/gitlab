# frozen_string_literal: true

module Ci
  class TestCase < ApplicationRecord
    extend Gitlab::Ci::Model

    has_many :test_case_failures, class_name: 'Ci::TestCaseFailure'

    belongs_to :project

    class << self
      def find_or_create_by_batch(project, test_case_keys)
        # Insert records first. Existing ones will be skipped.
        insert_all(test_case_attrs(project, test_case_keys))

        # Find all matching records now that we are sure they all are persisted.
        where(project_id: project.id, key_hash: test_case_keys)
      end

      private

      def test_case_attrs(project, test_case_keys)
        # NOTE: Rails 6.1 will add support for insert_all on relation so that
        # we will be able to do project.test_cases.insert_all.
        test_case_keys.map do |hashed_key|
          { project_id: project.id, key_hash: hashed_key }
        end
      end
    end
  end
end

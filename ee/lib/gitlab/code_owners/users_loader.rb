# frozen_string_literal: true

module Gitlab
  module CodeOwners
    class UsersLoader
      def initialize(project, extractor)
        @project = project
        @extractor = extractor
      end

      # Generate a list of all project members who are mentioned in the
      #   CODEOWNERS file, and load them to the matching entry.
      #
      def load_to(entries)
        members = project.members_among(users)

        entries.each do |entry|
          entry.add_matching_users_from(members)
        end
      end

      private

      attr_reader :extractor, :project

      def users
        return User.none if extractor.references.empty?

        relations = []
        relations << User.by_any_email(extractor.emails) if extractor.emails.any?
        relations << User.by_username(extractor.names) if extractor.names.any?

        User.from_union(relations).with_emails
      end
    end
  end
end

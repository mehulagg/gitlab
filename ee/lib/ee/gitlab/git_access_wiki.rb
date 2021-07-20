# frozen_string_literal: true

module EE
  module Gitlab
    module GitAccessWiki
      extend ::Gitlab::Utils::Override
      include GeoGitAccess

      ERROR_MESSAGES = {
        write_to_group_wiki: "You are not allowed to write to this group's wiki.",
        group_not_found: 'The group you were looking for could not be found.',
        no_group_repo: 'A repository for this group wiki does not exist yet.',
        repo_read_only: 'The repository is temporarily read-only. Please try again later.'
      }.freeze

      override :group
      def group
        container.group if container.is_a?(GroupWiki)
      end

      override :check_container!
      def check_container!
        super

        check_group! if group?
      end

      override :check_push_access!
      def check_push_access!
        return super unless group?

        if group.repository_read_only?
          raise ::Gitlab::GitAccess::ForbiddenError, ERROR_MESSAGES[:repo_read_only]
        end

        check_change_access!
      end

      override :write_to_wiki_message
      def write_to_wiki_message
        return ERROR_MESSAGES[:write_to_group_wiki] if group?

        super
      end

      override :no_repo_message
      def no_repo_message
        return ERROR_MESSAGES[:no_group_repo] if group?

        super
      end

      private

      def check_group!
        raise ::Gitlab::GitAccess::NotFoundError, ERROR_MESSAGES[:group_not_found] unless can_read_group?
      end

      def can_read_group?
        return true if geo?

        if user
          user.can?(:read_group, group)
        else
          Guest.can?(:read_group, group)
        end
      end
    end
  end
end

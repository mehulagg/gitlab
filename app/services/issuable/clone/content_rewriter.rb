# frozen_string_literal: true

module Issuable
  module Clone
    class ContentRewriter < ::Issuable::Clone::BaseService
      include RewriteContent

      def initialize(current_user, original_entity, new_entity)
        @current_user = current_user
        @original_entity = original_entity
        @new_entity = new_entity
        @project = original_entity.project
      end

      def execute
        rewrite_description
        copy_award_emoji
        copy_notes
      end

      private

      def rewrite_description
        new_entity.update(description: rewrite_content(original_entity.description, old_project, new_parent, current_user))
      end

      def copy_award_emoji
        AwardEmojis::CopyService.new(original_entity, new_entity).execute
      end

      def copy_notes
        Notes::CopyService.new(original_entity, new_entity, current_user).execute
      end
    end
  end
end

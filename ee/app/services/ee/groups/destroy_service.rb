# frozen_string_literal: true

module EE
  module Groups
    module DestroyService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        super.tap do |group|
          delete_dependency_proxy_blobs(group)

          unless group&.persisted?
            log_audit_event

            if ::Gitlab::Geo.primary? && group.group_wiki_repository
              group.group_wiki_repository.replicator.handle_after_destroy
            end
          end
        end
      end

      private

      def delete_dependency_proxy_blobs(group)
        # the blobs reference files that need to be destroyed that cascade delete
        # does not remove
        group.dependency_proxy_blobs.destroy_all # rubocop:disable Cop/DestroyAll
      end

      def log_audit_event
        ::AuditEventService.new(
          current_user,
          group,
          action: :destroy
        ).for_group.security_event
      end
    end
  end
end

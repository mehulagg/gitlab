# frozen_string_literal: true

module EE
  module Noteable
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    class_methods do
      # We can't specify `override` here:
      # https://gitlab.com/gitlab-org/gitlab-foss/issues/50911
      def replyable_types
        super + %w[Epic Vulnerability]
      end
    end

    override :note_etag_key
    def note_etag_key
      case self
      when Epic
        ::Gitlab::Routing.url_helpers.group_epic_notes_path(group, self)
      when ::Vulnerability
        ::Gitlab::Routing.url_helpers.project_security_vulnerability_notes_path(project, self)
      else
        super
      end
    end
  end
end

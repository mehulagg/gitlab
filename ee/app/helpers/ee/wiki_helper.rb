# frozen_string_literal: true

module EE
  module WikiHelper
    extend ::Gitlab::Utils::Override

    override :wiki_attachment_upload_url
    def wiki_attachment_upload_url
      case @wiki.container
      when Group
        expose_url(api_v4_groups_wikis_attachments_path(id: @wiki.container.id))
      else
        super
      end
    end
  end
end

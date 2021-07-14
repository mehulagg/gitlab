# frozen_string_literal: true

module ExternalLinkHelper
  include ActionView::Helpers::TextHelper

  def external_link(body, url, options = {})
    link_to url, { target: '_blank', rel: 'noopener noreferrer' }.merge(options) do
      "#{sanitize(body)}#{sprite_icon('external-link', css_class: 'gl-ml-1')}"
    end
  end
end

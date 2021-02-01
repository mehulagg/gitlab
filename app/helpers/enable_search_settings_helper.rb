# frozen_string_literal: true

module EnableSearchSettingsHelper
  def enable_search_settings
    content_for :before_content do
      render "shared/search_settings"
    end
  end
end

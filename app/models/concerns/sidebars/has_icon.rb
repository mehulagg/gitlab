# frozen_string_literal: true

module Sidebars
  module HasIcon
    def sprite_icon
      nil
    end

    def image_path
      nil
    end

    def image_html_options
      {}
    end

    def icon_or_image?
      sprite_icon || image_path
    end

    def sprite_icon_html_options
      {}
    end
  end
end

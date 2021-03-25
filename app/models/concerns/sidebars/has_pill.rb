# frozen_string_literal: true

module Sidebars
  module HasPill
    def has_pill?
      false
    end

    def pill_count
      raise NotImplementedError
    end

    def pill_html_options
      {}
    end
  end
end

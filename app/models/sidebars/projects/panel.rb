# frozen_string_literal: true

module Sidebars
  module Projects
    class Panel < ::Sidebars::Panel
      override :aria_label
      def aria_label
        _('Project navigation')
      end
    end
  end
end

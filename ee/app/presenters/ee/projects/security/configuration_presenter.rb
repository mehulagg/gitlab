# frozen_string_literal: true

module EE
  module Projects
    module Security
      module ConfigurationPresenter
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :to_h
        def to_h
          super.merge({
            can_toggle_auto_fix_settings: "EE"
          })
        end
      end
    end
  end
end

# frozen_string_literal: true

module EE
  module NotificationRecipients
    module Builder
      module Default
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        class_methods do
          extend ::Gitlab::Utils::Override

          override :mention_type_actions
          def mention_type_actions
            super.append(:new_epic)
          end
        end

        override :add_watchers
        def add_watchers
          if project
            super
          else # for group level targets
            add_group_watchers
          end
        end
      end
    end
  end
end

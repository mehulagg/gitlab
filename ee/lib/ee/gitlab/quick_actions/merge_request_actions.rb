# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module MergeRequestActions
        extend ActiveSupport::Concern
        include ::Gitlab::QuickActions::Dsl

        included do
          desc _('Depends on')
          explanation do |dependencies|
            _("Sets this merge request to depend on %{dependencies}.") % { dependencies: dependencies.map(&:to_reference).join(', ') }
          end
          execution_message do |dependencies|
            _("Sets this merge request to depend on %{dependencies}.") % { dependencies: dependencies.map(&:to_reference).join(', ') }
          end
          params '!<merge_request>'
          parse_params do |merge_request_param|
            extract_references(merge_request_param, :merge_request)
          end
          types MergeRequest
          condition do
            quick_action_target.new_record? ||
              current_user.can?(:"update_#{quick_action_target.to_ability_name}", quick_action_target)
          end
          command :depends_on do |dependencies|
            @updates[:blocking_merge_request_references] = dependencies
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module EE
  module API
    module Entities
      module List
        extend ActiveSupport::Concern

        prepended do
          expose :milestone, using: ::API::Entities::Milestone, if: -> (entity, _) { entity.milestone? }
          expose :user, as: :assignee, using: ::API::Entities::UserSafe, if: -> (entity, _) { entity.assignee? }
          expose :max_issue_count, if: -> (list, _) { list.wip_limits_available? }
          expose :max_issue_weight, if: -> (list, _) { list.wip_limits_available? }
          expose :limit_metric, if: -> (list, _) { list.wip_limits_available? }
        end
      end
    end
  end
end

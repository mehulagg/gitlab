# frozen_string_literal: true

module EE
  module API
    module Entities
      module UserBasic
        extend ActiveSupport::Concern

        prepended do
          expose :gitlab_employee?, as: :is_gitlab_employee, if: proc { ::Gitlab.com? && ::Feature.enabled?(:gitlab_employee_badge) }
          expose :email, if: -> (user, options) { user.managed_by?(options[:current_user]) }
        end
      end
    end
  end
end

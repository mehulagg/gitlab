# frozen_string_literal: true

module EE
  module API
    module Entities
      module UserDetailsWithAdmin
        extend ActiveSupport::Concern

        prepended do
          expose :plan do |user|
            user.namespace.try(:gitlab_subscription)&.plan_name
          end

          expose :trial do |user|
            user.namespace.try(:trial?)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module EE
  module API
    module Entities
      class ApprovalRuleShort < Grape::Entity
        expose :id, :name, :rule_type
      end
    end
  end
end

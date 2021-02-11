# frozen_string_literal: true

module API
  module Entities
    class ExternalApprovalRule < Grape::Entity
      expose :id
      expose :name
      expose :project_id
      expose :external_url
      expose :protected_branches
    end
  end
end

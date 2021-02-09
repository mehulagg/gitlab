# frozen_string_literal: true

module EE
  module API
    module Entities
      # @deprecated
      class ApproverGroup < Grape::Entity
        expose :group, using: ::API::Entities::Group
      end
    end
  end
end

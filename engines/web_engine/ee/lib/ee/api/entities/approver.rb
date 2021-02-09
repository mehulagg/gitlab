# frozen_string_literal: true

module EE
  module API
    module Entities
      # @deprecated
      class Approver < Grape::Entity
        expose :user, using: ::API::Entities::UserBasic
      end
    end
  end
end

# frozen_string_literal: true

module EE
  module API
    module Entities
      module ProtectedRefAccess
        extend ActiveSupport::Concern

        prepended do
          expose :user_id
          expose :group_id
        end
      end
    end
  end
end

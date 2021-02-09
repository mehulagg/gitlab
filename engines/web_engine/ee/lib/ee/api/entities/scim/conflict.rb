# frozen_string_literal: true

module EE
  module API
    module Entities
      module Scim
        class Conflict < Error
          STATUS = 409
        end
      end
    end
  end
end

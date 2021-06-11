# frozen_string_literal: true

module EE
  module API
    module Entities
      module Ci
        module Minutes
          class AdditionalPack < Grape::Entity
            expose :namespace_id
            expose :expires_at
            expose :number_of_minutes
            expose :purchase_xid
          end
        end
      end
    end
  end
end

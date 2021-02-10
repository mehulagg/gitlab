# frozen_string_literal: true

module EE
  module API
    module Entities
      class LdapGroup < Grape::Entity
        expose :cn
      end
    end
  end
end

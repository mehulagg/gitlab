# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class AuthorizationError < StandardError
        attr_reader :service

        def initialize(service, *args)
          @service = service
          super(*args)
        end
      end
    end
  end
end

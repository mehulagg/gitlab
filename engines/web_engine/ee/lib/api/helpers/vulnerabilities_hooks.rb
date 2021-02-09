# frozen_string_literal: true

module API
  module Helpers
    module VulnerabilitiesHooks
      extend ActiveSupport::Concern

      included do
        before do
          authenticate!
        end
      end
    end
  end
end

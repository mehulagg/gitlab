# frozen_string_literal: true

module EE
  module Types
    module TodoTargetEnum
      extend ActiveSupport::Concern

      prepended do
        value 'EPIC', value: 'Epic', description: 'An Epic.'
      end
    end
  end
end

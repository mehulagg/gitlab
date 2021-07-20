# frozen_string_literal: true

module Types
  class DastTargetTypeEnum < BaseEnum
    value 'WEBSITE', description: 'Website target.', value: 'website'
    value 'API', description: 'API target.', value: 'api'
  end
end

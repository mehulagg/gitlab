# frozen_string_literal: true

module Types
  class DastScanTypeEnum < BaseEnum
    value 'PASSIVE', description: 'Passive DAST scan. This scan will not make active attacks against the target site.'
    value 'ACTIVE', description: 'Active DAST scan. This scan will make active attacks against the target site.'
  end
end

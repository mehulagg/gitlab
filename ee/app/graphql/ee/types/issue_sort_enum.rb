# frozen_string_literal: true

module EE
  module Types
    module IssueSortEnum
      extend ActiveSupport::Concern

      prepended do
        value 'WEIGHT_ASC', 'Weight by ascending order', value: 'weight_asc'
        value 'WEIGHT_DESC', 'Weight by descending order', value: 'weight_desc'
        value 'PUBLISHED_ASC', 'Published issues shown last', value: :published_asc
        value 'PUBLISHED_DESC', 'Published issues shown first', value: :published_desc
      end
    end
  end
end

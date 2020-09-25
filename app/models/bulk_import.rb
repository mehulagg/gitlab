# frozen_string_literal: true

class BulkImport < ApplicationRecord
  belongs_to :user, optional: false

  has_one :configuration, class_name: 'ImportConfiguration'

  validates :source_type, presence: true

  enum source_type: { gitlab: 0 }
end

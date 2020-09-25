# frozen_string_literal: true

class BulkImport < ApplicationRecord
  belongs_to :user, optional: false

  has_one :configuration, class_name: 'ImportConfiguration'
  has_many :entities, class_name: 'ImportEntity'

  validates :source_type, presence: true

  enum source_type: { gitlab: 0 }
end

# frozen_string_literal: true

module ComplianceManagement
  class Framework < ApplicationRecord
    include StripAttribute

    self.table_name = 'compliance_management_frameworks'

    strip_attributes :name, :color

    belongs_to :group

    validates :group, presence: true
    validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
    validates :description, presence: true, length: { maximum: 255 }
    validates :color, color: true, allow_blank: false, length: { maximum: 10 }
    validates :group_id, uniqueness: { scope: [:name] }
  end
end

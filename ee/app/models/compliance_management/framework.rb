# frozen_string_literal: true

module ComplianceManagement
  class Framework < ApplicationRecord
    include StripAttribute
    include IgnorableColumns

    self.table_name = 'compliance_management_frameworks'

    ignore_columns :group_id, remove_after: '2020-12-06', remove_with: '13.7'

    strip_attributes :name, :color

    belongs_to :namespace

    validates :namespace, presence: true
    validates :name, presence: true, length: { maximum: 255 }
    validates :description, presence: true, length: { maximum: 255 }
    validates :color, color: true, allow_blank: false, length: { maximum: 10 }
    validates :namespace_id, uniqueness: { scope: :name }
  end
end

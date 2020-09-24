# frozen_string_literal: true

module ComplianceManagement
  class Framework < ApplicationRecord
    self.table_name = 'compliance_management_frameworks'

    DEFAULT_FRAMEWORKS = [
      {
        name: 'GDPR',
        description: 'General Data Protection Regulation',
        color: '#1aaa55',
        id: 1
      },
      {
        name: 'HIPAA',
        description: 'Health Insurance Portability and Accountability Act',
        color: '#1f75cb',
        id: 2
      },
      {
        name: 'PCI-DSS',
        description: 'Payment Card Industry-Data Security Standard',
        color: '#6666c4',
        id: 3
      },
      {
        name: 'SOC 2',
        description: 'Service Organization Control 2',
        color: '#dd2b0e',
        id: 4
      },
      {
        name: 'SOX',
        description: 'Sarbanes-Oxley',
        color: '#fc9403',
        id: 5
      }
    ].freeze

    before_validation :strip_whitespace_from_attrs

    validates :name, presence: true, length: { maximum: 255 }
    validates :description, presence: true, length: { maximum: 255 }
    validates :color, color: true, allow_blank: false, length: { maximum: 7 }

    def display_name
      "#{name} - #{description}"
    end

    private

    def strip_whitespace_from_attrs
      %w(color name).each { |attr| self[attr] = self[attr]&.strip }
    end

    def self.ensure_default_frameworks!
      ComplianceManagement::Framework::DEFAULT_FRAMEWORKS.each do |framework|
        ComplianceManagement::Framework.create(framework)
      end
    end
  end
end

# frozen_string_literal: true

module ComplianceManagement
  class Framework < ApplicationRecord
    include StripAttribute
    include IgnorableColumns

    DefaultFramework = Struct.new(:name, :description, :color, :identifier, :id) do
      def to_framework_params
        to_h.except(:id, :identifier)
      end
    end

    DEFAULT_FRAMEWORKS = [
      DefaultFramework.new(
        'GDPR',
        'General Data Protection Regulation',
        '#1aaa55',
        :gdpr,
        1
      ).freeze,
      DefaultFramework.new(
        'HIPAA',
        'Health Insurance Portability and Accountability Act',
        '#1f75cb',
        :hipaa,
        2
      ).freeze,
      DefaultFramework.new(
        'PCI-DSS',
        'Payment Card Industry-Data Security Standard',
        '#6666c4',
        :pci_dss,
        3
      ).freeze,
      DefaultFramework.new(
        'SOC 2',
        'Service Organization Control 2',
        '#dd2b0e',
        :soc_2,
        4
      ).freeze,
      DefaultFramework.new(
        'SOX',
        'Sarbanes-Oxley',
        '#fc9403',
        :sox,
        5
      ).freeze
    ].freeze

    DEFAULT_FRAMEWORKS_BY_IDENTIFIER = DEFAULT_FRAMEWORKS.index_by(&:identifier).freeze

    self.table_name = 'compliance_management_frameworks'

    ignore_columns :group_id, remove_after: '2020-12-06', remove_with: '13.7'

    strip_attributes :name, :color

    belongs_to :namespace

    validates :namespace, presence: true
    validates :name, presence: true, length: { maximum: 255 }
    validates :description, presence: true, length: { maximum: 255 }
    validates :color, color: true, allow_blank: false, length: { maximum: 10 }
    validates :namespace_id, uniqueness: { scope: :name }

    def configured_in_application_settings?
      default_framework_definition = DEFAULT_FRAMEWORKS.find { |framework| framework.name.eql?(name) }
      return false unless default_framework_definition

      ::Gitlab::CurrentSettings.current_application_settings.compliance_frameworks.include?(default_framework_definition.id)
    end
  end
end

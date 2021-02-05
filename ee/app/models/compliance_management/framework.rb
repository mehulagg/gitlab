# frozen_string_literal: true

module ComplianceManagement
  class Framework < ApplicationRecord
    include StripAttribute
    include IgnorableColumns
    include Gitlab::Utils::StrongMemoize

    DefaultFramework = Struct.new(:name, :description, :color, :identifier, :id) do
      def to_framework_params
        to_h.slice(:name, :description, :color)
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

    DEFAULT_FRAMEWORKS_BY_IDENTIFIER = DEFAULT_FRAMEWORKS.index_by(&:identifier).with_indifferent_access.freeze

    self.table_name = 'compliance_management_frameworks'

    ignore_columns :group_id, remove_after: '2020-12-06', remove_with: '13.7'

    strip_attributes :name, :color

    belongs_to :namespace
    has_many :project_settings, class_name: 'ComplianceManagement::ComplianceFramework::ProjectSettings'
    has_many :projects, through: :project_settings

    validates :namespace, presence: true
    validates :name, presence: true, length: { maximum: 255 }
    validates :description, presence: true, length: { maximum: 255 }
    validates :color, color: true, allow_blank: false, length: { maximum: 10 }
    validates :regulated, presence: true
    validates :namespace_id, uniqueness: { scope: :name }
    validates :pipeline_configuration_full_path, length: { maximum: 255 }

    scope :with_projects, ->(project_ids) { includes(:projects).where(projects: { id: project_ids }) }
    scope :with_namespaces, ->(namespace_ids) { includes(:namespace).where(namespaces: { id: namespace_ids })}

    def default_framework_definition
      strong_memoize(:default_framework_definition) do
        DEFAULT_FRAMEWORKS.find { |framework| framework.name.eql?(name) }
      end
    end

    def self.find_or_create_legacy_default_framework(project, framework_identifier)
      framework_params = ComplianceManagement::Framework::DEFAULT_FRAMEWORKS_BY_IDENTIFIER.fetch(framework_identifier).to_framework_params
      root_namespace = project.root_namespace

      # Framework is associated with the root group, there could be a case where the framework is already there.
      ComplianceManagement::Framework
        .create_with(framework_params)
        .safe_find_or_create_by(namespace_id: root_namespace.id, name: framework_params[:name])
    end
  end
end

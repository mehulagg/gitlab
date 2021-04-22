# frozen_string_literal: true

module BulkImports
  class Export < ApplicationRecord
    include Gitlab::Utils::StrongMemoize

    self.table_name = 'bulk_import_exports'

    belongs_to :project, optional: true
    belongs_to :group, optional: true

    has_one :upload, class_name: 'BulkImports::ExportUpload'

    validates :project, presence: true, unless: :group
    validates :group, presence: true, unless: :project
    validates :relation, :status, presence: true

    validate :exportable_relation?

    state_machine :status, initial: :started do
      state :started, value: 0
      state :finished, value: 1
      state :failed, value: -1

      event :start do
        transition started: :started
        transition finished: :started
        transition failed: :started
      end

      event :finish do
        transition started: :finished
        transition failed: :failed
      end

      event :fail_op do
        transition any => :failed
      end
    end

    def exportable_relation?
      return unless exportable

      allowed_relations = ::Gitlab::ImportExport.top_level_relations(exportable.class.name)

      errors.add(:relation, 'Unsupported exportable relation') unless allowed_relations.include?(relation)
    end

    def exportable
      project || group
    end

    def relation_definition
      config.exportable_tree[:include].find { |include| include[relation.to_sym] }
    end

    def config
      strong_memoize(:config) do
        case exportable
        when ::Project
          Exports::ProjectConfig.new(exportable)
        when ::Group
          Exports::GroupConfig.new(exportable)
        end
      end
    end
  end
end

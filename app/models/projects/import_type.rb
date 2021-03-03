# frozen_string_literal: true

module Projects
  class ImportType < ::ApplicationRecord
    self.table_name = 'project_import_types'

    belongs_to :project

    validates :name, presence: true
  end
end

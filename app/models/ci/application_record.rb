# frozen_string_literal: true

module Ci
  # TODO: https://gitlab.com/groups/gitlab-org/-/epics/6168
  #
  # Do not use this yet outside of `ci_instance_variables`.
  # This class is part of a migration to move all CI classes to a new separate database.
  # Initially we are only going to be moving the `Ci::InstanceVariable` model and it will be duplicated in the main and CI tables
  # Do not extend this class in any other models.
  class ApplicationRecord < ::ApplicationRecord
    self.abstract_class = true
    self.schema_name = :gitlab_ci

    # TODO: CI Vertical
    if Gitlab::Database.has_config?(:ci)
      connects_to database: { writing: :ci, reading: :ci }
    end

    def self.table_name_prefix
      "ci_"
    end

    def self.model_name
      @model_name ||= ActiveModel::Name.new(self, nil, self.name.demodulize)
    end
  end
end

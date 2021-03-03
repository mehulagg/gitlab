# frozen_string_literal: true

module Dast
  Branch = Struct.new(:project) do
    def name
      project.default_branch
    end

    def exists
      project.repository.branch_exists?(project.default_branch)
    end
  end
end

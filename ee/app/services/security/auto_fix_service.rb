# frozen_string_literal: true

module Security
  class AutoFixService
    def initialize(project)
      @project = project
    end

    def execute
      # check auto-fix setting
      # get all possible vulns with MRs
      # create MRs
    end
  end
end

# frozen_string_literal: true

module DesignManagement
  class DesignService < ::BaseService
    def initialize(project, user, params = {})
      super

      @issue = params.fetch(:issue)
    end

    # Accessors common to all subclasses:

    attr_reader :issue

    def target_branch
      project.default_branch_or_main
    end

    def collection
      issue.design_collection
    end
    alias_method :design_collection, :collection

    def repository
      collection.repository
    end

    def project
      issue.project
    end
  end
end

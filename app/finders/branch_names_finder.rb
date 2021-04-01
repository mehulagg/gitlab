# frozen_string_literal: true

class BranchNamesFinder
  attr_reader :repository, :params

  def initialize(repository, params = {})
    @repository = repository
    @params = params
  end

  def execute
    repository.search_branch_names(search)
  end

  private

  def search
    @params[:search].presence
  end
end

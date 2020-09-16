# frozen_string_literal: true

module Autocomplete
  class VulnerabilitiesFinder
    attr_reader :current_user, :vulnerable, :params

    # current_user - the User object of the user that wants to view the list of Vulnerabilities
    #
    # vulnerable - any object that has a #vulnerabilities method that returns a collection of vulnerabilitie
    # params - a Hash containing additional parameters to set
    #
    # The supported parameters are those supported by
    # `Security::VulnerabilitiesFinder`.
    def initialize(current_user, vulnerable, params = {})
      @current_user = current_user
      @vulnerable = vulnerable
      @params = params
    end

    def execute
      ::Security::VulnerabilitiesFinder # rubocop: disable CodeReuse/Finder
        .new(vulnerable, params)
        .execute
        .select { |vulnerability| vulnerability.visible_to_user?(current_user) }
    end
  end
end

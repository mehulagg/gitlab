# frozen_string_literal: true

module DesignManagement
  module RunsDesignActions
    NoActions = Class.new(StandardError)

    # this concern requires the following methods to be implemented:
    #   target_branch, repository, commit_message
    #
    # @raise [NoActions] if actions are empty
    def run_actions(actions, current_user)
      raise NoActions if actions.empty?

      repository.create_if_not_exists
      sha = repository.multi_action(current_user,
                                    branch_name: target_branch,
                                    message: commit_message,
                                    actions: actions.map(&:gitaly_action))

      ::DesignManagement::Version.create_for_designs(actions, sha, current_user)
    end
  end
end

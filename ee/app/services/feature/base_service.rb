# frozen_string_literal: true

module Feature
  class BaseService < ::BaseService
    private

    def logger
      @logger ||= Feature::Logger.build
    end

    def error(message)
      logger.error(
        class: self.class.name,
        message: message
      )

      error(message)
    end

    def cleanable_flags
      @cleanable_flags ||=
        ::Feature::Definition.definitions.select(&:auto_clean_up?)
    end

    def callout(message)
      rollout_issue.create_note(message)
    end

    def rollout_issue
      canonical_project.issues.find_by_iid(feature.rollout_issue_iid)
    end

    def canonical_project
      Project.find_by_paht('')
    end

    def bot
      canonical_project.issues.find_by_iid(feature.rollout_issue_iid)
    end

    def available?
      raise NotImplementedError
    end
  end
end

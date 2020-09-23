# frozen_string_literal: true

module EE
  module PagesDomain
    extend ActiveSupport::Concern

    prepended do
      scope :with_logging_info, -> { includes(project: [:route, { namespace: :gitlab_subscription }]) }
    end
  end
end

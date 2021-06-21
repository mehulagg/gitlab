# frozen_string_literal: true

require_relative './after_next_helpers'

module IntegrationsHelper
  include AfterNextHelpers

  def expect_execution_of(integration_class, *args)
    expect_next(integration_class, *args).to receive(:execute)
  end
end

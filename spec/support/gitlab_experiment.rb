# frozen_string_literal: true

# Require the provided spec helper and matchers.
require 'gitlab/experiment/rspec'

module Gitlab::Experiment::RSpecHelpers
  def stub_experiments(experiments)
    # quick fix: https://gitlab.com/gitlab-org/gitlab/-/issues/300104
    experiments.each { |name, _| Feature.persist_used!(name) }

    super
  end
end

# Disable all caching for experiments in tests.
Gitlab::Experiment::Configuration.cache = nil

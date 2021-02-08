# frozen_string_literal: true

# Require the provided spec helper and matchers.
require 'gitlab/experiment/rspec'

# This is a temporary fix until we have a larger discussion around the
# challenges raised in https://gitlab.com/gitlab-org/gitlab/-/issues/300104
class ApplicationExperiment < Gitlab::Experiment # rubocop:disable Gitlab/NamespacedClass
  def initialize(name = nil, variant_name = nil, **context)
    super
    Feature.persist_used!(feature_flag_name)
  end
end

# Disable all caching for experiments in tests.
Gitlab::Experiment::Configuration.cache = nil

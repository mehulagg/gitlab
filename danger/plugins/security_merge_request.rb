# frozen_string_literal: true

require_relative '../../tooling/danger/security_merge_request'

module Danger
  class FeatureFlag < Plugin
    # Put the helper code somewhere it can be tested
    include Tooling::Danger::SecurityMergeRequest
  end
end


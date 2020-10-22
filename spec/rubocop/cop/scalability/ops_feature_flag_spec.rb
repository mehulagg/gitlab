# frozen_string_literal: true

require 'fast_spec_helper'
require 'rubocop'
require 'rspec-parameterized'

require_relative '../../../../rubocop/cop/scalability/ops_feature_flag'

RSpec.describe RuboCop::Cop::Scalability::OpsFeatureFlag, type: :rubocop do
  include CopHelper
  using RSpec::Parameterized::TableSyntax

  subject(:cop) { described_class.new }

  where(:code, :offenses) do
    "Feature.enabled?(:my_flag)"                                            | 0
    "Feature.enabled?(:my_flag, type: :development)"                        | 0
    "Feature.enabled?(:my_flag, type: :ops)"                                | 1
    "Feature.enabled?(:my_flag, type: :development, default_enabled: true)" | 0
    "Feature.enabled?(:my_flag, type: :ops, default_enabled: true)"         | 1

    "Feature.disabled?(:my_flag)"                                            | 0
    "Feature.disabled?(:my_flag, type: :development)"                        | 0
    "Feature.disabled?(:my_flag, type: :ops)"                                | 1
    "Feature.disabled?(:my_flag, type: :development, default_enabled: true)" | 0
    "Feature.disabled?(:my_flag, type: :ops, default_enabled: true)"         | 1

    "push_frontend_feature_flag(:my_flag)"                                            | 0
    "push_frontend_feature_flag(:my_flag, type: :development)"                        | 0
    "push_frontend_feature_flag(:my_flag, type: :ops)"                                | 1
    "push_frontend_feature_flag(:my_flag, type: :development, default_enabled: true)" | 0
    "push_frontend_feature_flag(:my_flag, type: :ops, default_enabled: true)"         | 1
  end

  with_them do
    it do
      inspect_source(code)

      expect(cop.offenses.size).to eq(offenses)
    end
  end
end

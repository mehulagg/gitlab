# frozen_string_literal: true

require 'fast_spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../../../../rubocop/cop/gitlab/mark_used_feature_flags'

RSpec.describe RuboCop::Cop::Gitlab::MarkUsedFeatureFlags do
  let(:defined_feature_flags) do
    %w[foo_bar foo_baz]
  end

  subject(:cop) { described_class.new }

  before do
    allow(described_class).to receive(:defined_feature_flags).and_return(defined_feature_flags)
  end

  def feature_flag_path(feature_flag_name)
    File.expand_path("../../../../tmp/feature_flags/#{feature_flag_name}.used", __dir__)
  end

  shared_examples 'sets flag as used' do |method_call, flags_to_be_set|
    it 'sets the flag as used' do
      Array(flags_to_be_set).each do |flag_to_be_set|
        expect(FileUtils).to receive(:touch).with(feature_flag_path(flag_to_be_set))
      end

      expect_no_offenses(method_call)
    end
  end

  shared_examples 'does not set any flags as used' do |method_call|
    it 'sets the flag as used' do
      expect(FileUtils).not_to receive(:touch)

      expect_no_offenses(method_call)
    end
  end

  %w[Feature.enabled? Feature.disabled? push_frontend_feature_flag].each do |feature_flag_method|
    context "#{feature_flag_method} method" do
      context 'a string feature flag' do
        include_examples 'sets flag as used', %Q|#{feature_flag_method}("foo")|, 'foo'
      end

      context 'a symbol feature flag' do
        include_examples 'sets flag as used', %Q|#{feature_flag_method}(:foo)|, 'foo'
      end

      context 'a dynamic string feature flag with a string prefix' do
        include_examples 'sets flag as used', %Q|#{feature_flag_method}("foo_\#{bar}")|, %w[foo_bar foo_baz]
      end

      context 'a dynamic symbol feature flag with a string prefix' do
        include_examples 'sets flag as used', %Q|#{feature_flag_method}(:"foo_\#{bar}")|, %w[foo_bar foo_baz]
      end

      context 'a dynamic string feature flag with a string prefix and suffix' do
        include_examples 'does not set any flags as used', %Q|#{feature_flag_method}(:"foo_\#{bar}_baz")|
      end
    end
  end
end

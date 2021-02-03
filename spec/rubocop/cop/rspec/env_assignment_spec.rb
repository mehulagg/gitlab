# frozen_string_literal: true

require 'fast_spec_helper'

require 'rubocop'
require_relative '../../../../rubocop/cop/rspec/env_assignment'

RSpec.describe RuboCop::Cop::RSpec::EnvAssignment do
  offense_call_single_quotes_key = %(ENV['FOO'] = 'bar').freeze
  offense_call_double_quotes_key = %(ENV["FOO"] = 'bar').freeze

  let(:source_file) { 'spec/foo_spec.rb' }

  subject(:cop) { described_class.new }

  shared_examples 'an offensive and correction ENV#[]= call' do |content, autocorrected_content|
    it "registers an offense for `#{content}`" do
      expect_offense(<<~CODE)
        #{content}
        ^^^^^^^^^^^^^^^^^^ Don't assign to ENV, use `stub_env` instead.
      CODE

      expect_correction(<<~CODE)
        #{autocorrected_content}
      CODE
    end
  end

  context 'with a key using single quotes' do
    it_behaves_like 'an offensive and correction ENV#[]= call', offense_call_single_quotes_key, %(stub_env('FOO', 'bar'))
  end

  context 'with a key using double quotes' do
    it_behaves_like 'an offensive and correction ENV#[]= call', offense_call_double_quotes_key, %(stub_env("FOO", 'bar'))
  end
end

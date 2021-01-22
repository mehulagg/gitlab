# frozen_string_literal: true

require 'fast_spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../../../../rubocop/cop/gitlab/override'

RSpec.describe RuboCop::Cop::Gitlab::Override do
  subject(:cop) { described_class.new }

  describe 'registers an offense when' do
    it 'missing override super withour args' do
      expect_offense(<<~RUBY)
        def foo
        ^^^^^^^ #{missing_override(:foo)}
          super
        end
      RUBY
    end

    it 'missing override for super with args' do
      expect_offense(<<~RUBY)
        def foo
        ^^^^^^^ #{missing_override(:foo)}
          super()
        end
      RUBY
    end

    it 'override name mismatch' do
      expect_offense(<<~RUBY)
        override :bar
        def foo
        ^^^^^^^ #{override_mismatch(:foo, :bar)}
          super
      end
      RUBY
    end

    it 'missing override' do
      expect_offense(<<~RUBY)
        something :foo
        def foo
        ^^^^^^^ #{missing_override(:foo)}
          super
      end
      RUBY
    end
  end

  describe 'does not register an offense if' do
    it 'without super' do
      expect_no_offenses(<<~RUBY)
        def foo
        end
      RUBY
    end

    it 'override is used for super without args' do
      expect_no_offenses(<<~RUBY)
        override :foo
        def foo
          super
        end
      RUBY
    end

    it 'override is used for super with args' do
      expect_no_offenses(<<~RUBY)
        override :foo
        def foo
          super()
        end
      RUBY
    end
  end

  private

  def missing_override(name)
    message_for(described_class::MSG_MISSING_OVERRIDE, name: name)
  end

  def override_mismatch(name, wrong_name)
    message_for(described_class::MSG_OVERRIDE_NAME_MISMATCH, name: name, wrong_name: wrong_name)
  end

  def message_for(msg, **args)
    format(msg + described_class::LINK, **args)
  end
end

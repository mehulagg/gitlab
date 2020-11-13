# frozen_string_literal: true

require 'fast_spec_helper'
require 'rubocop'
require_relative '../../../../rubocop/cop/lint/last_keyword_argument'

RSpec.describe RuboCop::Cop::Lint::LastKeywordArgument, type: :rubocop do
  include CopHelper

  subject(:cop) { described_class.new }

  context 'file does not exist' do
    before do
      allow(File).to receive(:exist?).and_return(false)
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~SOURCE)
        users.call(params)
      SOURCE
    end
  end

  context 'file does exist' do
    before do
      allow(File).to receive(:exist?).and_return(true)

      allow(File).to receive(:read).and_return(<<~DATA)
----
create_service.rb:1: warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call
user.rb:17: warning: The called method `call' is defined here
----
/Users/tkuah/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/gems/batch-loader-1.4.0/lib/batch_loader/graphql.rb:38: warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call
/Users/tkuah/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/gems/batch-loader-1.4.0/lib/batch_loader.rb:26: warning: The called method `batch' is defined here
      DATA
    end

    it 'registers an offense' do
      expect_offense(<<~SOURCE, 'create_service.rb')
        users.call(params)
                   ^^^^^^ Using the last argument as keyword parameters is deprecated
      SOURCE

      expect_correction(<<~SOURCE)
        users.call(**params)
      SOURCE
    end

    it 'registers an offense and corrects by converting hash to kwarg' do
      expect_offense(<<~SOURCE, 'create_service.rb')
        users.call(id, { a: :b, c: :d })
                       ^^^^^^^^^^^^^^^^ Using the last argument as keyword parameters is deprecated
      SOURCE

      expect_correction(<<~SOURCE)
        users.call(id, a: :b, c: :d)
      SOURCE
    end

    it 'does not register an offense if already a kwarg', :aggregate_failures do
      expect_no_offenses(<<~SOURCE, 'create_service.rb')
        users.call(**params)
      SOURCE

      expect_no_offenses(<<~SOURCE, 'create_service.rb')
        users.call(id, a: :b, c: :d)
      SOURCE
    end

    it 'does not register an offense if the method name does not match' do
      expect_no_offenses(<<~SOURCE, 'create_service.rb')
        users.process(params)
      SOURCE
    end

    it 'does not register an offense if the line number does not match' do
      expect_no_offenses(<<~SOURCE, 'create_service.rb')
        users.process
        users.call(params)
      SOURCE
    end

    it 'does not register an offense if the filename does not match' do
      expect_no_offenses(<<~SOURCE, 'update_service.rb')
        users.call(params)
      SOURCE
    end
  end
end

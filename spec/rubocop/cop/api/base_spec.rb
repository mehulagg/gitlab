# frozen_string_literal: true

require 'fast_spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../../../../rubocop/cop/api/base'

RSpec.describe RuboCop::Cop::API::Base, type: :rubocop do
  include CopHelper

  subject(:cop) { described_class.new }

  let(:corrected) do
    <<~CORRECTED
      class SomeAPI < API::Base
      end
    CORRECTED
  end

  it 'adds an offense when inheriting from Grape::API' do
    expect_offense(<<~CODE)
      class SomeAPI < Grape::API
                      ^^^^^^^^^^ #{described_class::MSG}
      end
    CODE

    expect_correction(corrected)
  end

  it 'adds an offense when inheriting from Grape::API::Instance' do
    expect_offense(<<~CODE)
      class SomeAPI < Grape::API::Instance
                      ^^^^^^^^^^^^^^^^^^^^ #{described_class::MSG}
      end
    CODE

    expect_correction(corrected)
  end

  it 'does not add an offense when inheriting from BaseAPI' do
    expect_no_offenses(corrected)
  end
end

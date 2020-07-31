# frozen_string_literal: true

require 'fast_spec_helper'
require 'rubocop'
require_relative '../../../rubocop/cop/put_routes_under_scope'

RSpec.describe RuboCop::Cop::PutRoutesUnderScope, type: :rubocop do
  include CopHelper

  subject(:cop) { described_class.new }

  %w[resource resources get post put patch delete].each do |route_method|
    it "registers an offense when route is outside scope for `#{route_method}`" do
      offense = "#{route_method} :notes"
      marker = '^' * offense.size

      expect_offense(<<~PATTERN)
      scope(path: 'groups/*group_id/-', module: :groups) do
        resource :issues
      end

      #{offense}
      #{marker} Put new routes under /-/ scope
      PATTERN
    end
  end

  it 'does not register an offense when resource inside the scope' do
    expect_no_offenses(<<~PATTERN)
      scope(path: 'groups/*group_id/-', module: :groups) do
        resource :issues
        resource :notes
      end
    PATTERN
  end

  it 'does not register an offense when routes specify dash' do
    expect_no_offenses(<<~PATTERN)
      get '-', action: :foo
      post '-' => :foo
      delete :foo, path: '-/delete'
    PATTERN
  end

  it 'does not register an offense when resource is deep inside the scope' do
    expect_no_offenses(<<~PATTERN)
      scope(path: 'groups/*group_id/-', module: :groups) do
        resource :issues
        resource :projects do
          resource :issues do
            resource :notes
          end
        end
      end
    PATTERN
  end
end

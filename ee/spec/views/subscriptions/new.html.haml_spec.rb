# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'subscriptions/new' do
  it_behaves_like 'subscription form data', '#js-new-subscription'
end

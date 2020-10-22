# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'subscriptions/new' do
  before do
    allow(view).to receive(:subscription_data).and_return(
      setup_for_company: 'true',
      full_name: 'First Last',
      plan_data: '[{"id":"bronze_id","code":"bronze","price_per_year":48.0}]',
      plan_id: 'bronze_id'
    )
  end

  subject { render }

  it { is_expected.to have_selector("#checkout[data-setup-for-company='true']") }
  it { is_expected.to have_selector("#checkout[data-full-name='First Last']") }
  it { is_expected.to have_selector("#checkout[data-plan-data='[{\"id\":\"bronze_id\",\"code\":\"bronze\",\"price_per_year\":48.0}]']") }
  it { is_expected.to have_selector("#checkout[data-plan-id='bronze_id']") }
end

# frozen_string_literal: true
RSpec.shared_examples_for 'subscription form data' do |js_selector|
  before do
    allow(view).to receive(:subscription_data).and_return(
      setup_for_company: 'true',
      full_name: 'First Last',
      plan_data: '[{"id":"bronze_id","code":"bronze","price_per_year":48.0}]',
      plan_id: 'bronze_id',
      source: 'some_source'
    )
  end

  subject { render }

  it { is_expected.to have_selector("#{js_selector}[data-setup-for-company='true']") }
  it { is_expected.to have_selector("#{js_selector}[data-full-name='First Last']") }
  it { is_expected.to have_selector("#{js_selector}[data-plan-data='[{\"id\":\"bronze_id\",\"code\":\"bronze\",\"price_per_year\":48.0}]']") }
  it { is_expected.to have_selector("#{js_selector}[data-plan-id='bronze_id']") }
  it { is_expected.to have_selector("#{js_selector}[data-source='some_source']") }
end

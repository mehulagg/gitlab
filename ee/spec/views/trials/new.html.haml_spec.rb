# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'trials/new.html.haml' do
  include ApplicationHelper
  let_it_be(:remove_known_trial_form_fields_enabled) { false }
  let_it_be(:user) { build(:user) }

  before do
    allow(view).to receive(:current_user) { user }
    allow(view).to receive(:experiment_enabled?).with(:remove_known_trial_form_fields).and_return(remove_known_trial_form_fields_enabled)

    render
  end

  subject { rendered }

  it 'has fields for first, last and company names' do
    is_expected.to have_field('first_name')
    is_expected.to have_field('last_name')
    is_expected.to have_field('company_name')
  end

  context 'remove_known_trial_form_fields experiment is enabled' do
    let_it_be(:remove_known_trial_form_fields_enabled) { true }

    context 'the user has already values in first, last and company names' do
      let_it_be(:user) { build(:user, first_name: 'John', last_name: 'Doe', organization: 'ACME') }

      it 'has hidden fields' do
        is_expected.to have_field('first_name', type: :hidden)
        is_expected.to have_field('last_name', type: :hidden)
        is_expected.to have_field('company_name', type: :hidden)
      end
    end

    context 'the user empty values for first, last and company names' do
      let_it_be(:user) { build(:user, first_name: '', last_name: '', organization: '') }

      it 'has fields' do
        is_expected.to have_field('first_name')
        is_expected.to have_field('last_name')
        is_expected.to have_field('company_name')
      end
    end
  end
end

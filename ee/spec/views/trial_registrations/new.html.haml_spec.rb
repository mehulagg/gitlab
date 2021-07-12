# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'trial_registrations/new.html.haml' do
  let_it_be(:resource) { Users::AuthorizedBuildService.new(nil, {}).execute }

  before do
    allow(view).to receive(:resource).and_return(resource)
    allow(view).to receive(:resource_name).and_return(:user)
  end

  subject { render && rendered }

  describe 'trial_registration_with_reassurance experiment' do
    before do
      stub_experiments(trial_registration_with_reassurance: trial_registration_with_reassurance_variant)
    end

    context 'when in the control' do
      let_it_be(:trial_registration_with_reassurance_variant) { :control }

      it 'does not include the reassurance sidebar content' do
        is_expected.not_to have_content('No credit card required.')
      end
    end

    context 'when in the candidate' do
      let_it_be(:trial_registration_with_reassurance_variant) { :candidate }

      it 'includes the reassurance sidebar content' do
        is_expected.to have_content('No credit card required.')
      end
    end
  end
end

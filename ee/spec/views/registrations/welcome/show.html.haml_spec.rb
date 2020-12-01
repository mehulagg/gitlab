# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'registrations/welcome/show' do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:user) { User.new }

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:redirect_path).and_return(redirect_path)
    allow(view).to receive(:onboarding_issues_experiment_enabled?).and_return(onboarding_issues_experiment_enabled)
    allow(Gitlab).to receive(:com?).and_return(true)

    render
  end

  subject { rendered }

  where(:redirect_path, :onboarding_issues_experiment_enabled, :show_progress_bar, :flow, :is_continue) do
    '/-/subscriptions/new'    | false | true  | :subscription | true
    '/-/subscriptions/new'    | true  | true  | :subscription | true
    '/-/trials/new'           | false | false | :trial        | true
    '/-/trials/new'           | true  | false | :trial        | true
    '/-/invites/abc123'       | false | false | nil           | false
    '/-/invites/abc123'       | true  | false | nil           | false
    '/oauth/authorize/abc123' | false | false | nil           | false
    '/oauth/authorize/abc123' | true  | false | nil           | false
    nil                       | false | false | nil           | false
    nil                       | true  | true  | nil           | true
  end

  with_them do
    it 'shows the correct text for the :setup_for_company label' do
      expected_text = "Who will be using #{flow.nil? ? 'GitLab' : "this GitLab #{flow}"}?"

      is_expected.to have_selector('label[for="user_setup_for_company"]', text: expected_text)
    end

    it 'shows the correct text for the submit button' do
      expected_text = is_continue ? 'Continue' : 'Get started!'

      is_expected.to have_button(expected_text)
    end

    if params[:show_progress_bar]
      it { is_expected.to have_selector('#progress-bar') }
    else
      it { is_expected.not_to have_selector('#progress-bar') }
    end
  end
end

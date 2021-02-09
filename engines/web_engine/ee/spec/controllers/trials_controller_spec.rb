# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TrialsController do
  let_it_be(:user) { create(:user, email_opted_in: true, last_name: 'Doe') }
  let_it_be(:remove_known_trial_form_fields_context) do
    {
      first_name_present: user.first_name.present?,
      last_name_present: user.last_name.present?,
      company_name_present: user.organization.present?
    }
  end

  let_it_be(:trial_registration_with_social_signin_context) do
    {
      google_signon: user.identities.select { |id| id.provider == 'google_auth2'}.present?,
      github_signon: user.identities.select { |id| id.provider == 'github' }.present?
    }
  end

  let(:dev_env_or_com) { true }
  let(:logged_in) { true }

  before do
    allow(::Gitlab).to receive(:dev_env_or_com?).and_return(dev_env_or_com)
    sign_in(user) if logged_in
  end

  shared_examples 'an authenticated endpoint' do
    let(:success_status) { :ok }

    context 'when not authenticated' do
      let(:logged_in) { false }

      it { is_expected.to redirect_to(new_trial_registration_url) }
    end

    context 'when authenticated' do
      it { is_expected.to have_gitlab_http_status(success_status) }
    end
  end

  shared_examples 'a dot-com only feature' do
    let(:success_status) { :ok }

    context 'when not on gitlab.com and not in development environment' do
      let(:dev_env_or_com) { false }

      it { is_expected.to have_gitlab_http_status(:not_found) }
    end

    context 'when on gitlab.com or in dev environment' do
      it { is_expected.to have_gitlab_http_status(success_status) }
    end
  end

  describe '#new' do
    subject do
      get :new
      response
    end

    it 'calls record_experiment_user for the experiments' do
      expect(controller).to receive(:record_experiment_user).with(:remove_known_trial_form_fields, remove_known_trial_form_fields_context)
      expect(controller).to receive(:record_experiment_user).with(:trimmed_skip_trial_copy)
      expect(controller).to receive(:record_experiment_user).with(:trial_registration_with_social_signin, trial_registration_with_social_signin_context)

      subject
    end

    it_behaves_like 'an authenticated endpoint'
    it_behaves_like 'a dot-com only feature'
  end

  describe '#create_lead' do
    let(:post_params) { {} }
    let(:create_lead_result) { nil }

    before do
      allow_next_instance_of(GitlabSubscriptions::CreateLeadService) do |lead_service|
        expect(lead_service).to receive(:execute).and_return({ success: create_lead_result })
      end
    end

    subject do
      post :create_lead, params: post_params
      response
    end

    it_behaves_like 'an authenticated endpoint'
    it_behaves_like 'a dot-com only feature'

    context 'on success' do
      let(:create_lead_result) { true }

      it { is_expected.to redirect_to(select_trials_url) }

      context 'coming from about.gitlab.com' do
        let(:post_params) { { glm_source: 'about.gitlab.com' } }

        it 'records trial_onboarding_issues experiment users but does not redirect to onboarding' do
          expect(controller).to receive(:record_experiment_user).with(:trial_onboarding_issues)
          is_expected.to redirect_to(select_trials_url(glm_source: 'about.gitlab.com'))
        end

        context 'when experiment trial_onboarding_issues is enabled' do
          before do
            stub_experiment_for_subject(trial_onboarding_issues: true)
          end

          it 'records trial_onboarding_issues experiment users and redirects to onboarding' do
            expect(controller).to receive(:record_experiment_user).with(:trial_onboarding_issues)
            is_expected.to redirect_to(new_users_sign_up_group_path(glm_source: 'about.gitlab.com', trial_onboarding_flow: true))
          end
        end
      end
    end

    context 'on failure' do
      let(:create_lead_result) { false }

      it { is_expected.to render_template(:new) }
    end

    context 'request params to Lead Service' do
      let(:post_params) do
        {
          company_name: 'Gitlab',
          company_size: '1-99',
          first_name: user.first_name,
          last_name: user.last_name,
          phone_number: '1111111111',
          number_of_users: "20",
          country: 'IN'
        }
      end

      let(:extra_params) do
        {
          work_email: user.email,
          uid: user.id,
          skip_email_confirmation: true,
          gitlab_com_trial: true,
          provider: 'gitlab',
          newsletter_segment: user.email_opted_in
        }
      end

      let(:expected_params) do
        ActionController::Parameters.new(post_params).merge(extra_params).permit!
      end

      it 'sends appropriate request params' do
        expect_next_instance_of(GitlabSubscriptions::CreateLeadService) do |lead_service|
          expect(lead_service).to receive(:execute).with({ trial_user: expected_params }).and_return({ success: true })
        end

        subject
      end
    end
  end

  describe '#select' do
    def get_select
      get :select
    end

    subject do
      get_select
      response
    end

    it_behaves_like 'an authenticated endpoint'
    it_behaves_like 'a dot-com only feature'

    context 'when the group-only trials experiment is active' do
      before do
        stub_experiment(group_only_trials: true)
        stub_experiment_for_subject(group_only_trials: user_is_in_experiment?)
      end

      def expected_group_type
        user_is_in_experiment? ? 'experimental' : 'control'
      end

      where(user_is_in_experiment?: [true, false])

      with_them do
        it 'records the user as being part of the experiment' do
          expect { get_select }.to change { ExperimentUser.count }.by(1)
          expect(ExperimentUser.last.group_type).to eq(expected_group_type)
        end
      end
    end

    context 'when the group-only trials experiment is not active' do
      it 'does not record the user as being part of the experiment' do
        expect { get_select }.not_to change { ExperimentUser.count }
      end
    end
  end

  describe '#apply' do
    let_it_be(:namespace) { create(:namespace, owner_id: user.id, path: 'namespace-test') }

    let(:apply_trial_result) { nil }
    let(:post_params) { { namespace_id: namespace.id } }

    before do
      allow_any_instance_of(GitlabSubscriptions::ApplyTrialService).to receive(:execute) do
        { success: apply_trial_result }
      end
    end

    subject do
      post :apply, params: post_params
      response
    end

    it_behaves_like 'an authenticated endpoint'
    it_behaves_like 'a dot-com only feature'

    context 'on success' do
      let(:apply_trial_result) { true }

      it { is_expected.to redirect_to("/#{namespace.path}?trial=true") }
      it 'calls the record conversion method for the experiments' do
        expect(controller).to receive(:record_experiment_conversion_event).with(:remove_known_trial_form_fields)
        expect(controller).to receive(:record_experiment_conversion_event).with(:trimmed_skip_trial_copy)
        expect(controller).to receive(:record_experiment_conversion_event).with(:trial_registration_with_social_signin)

        subject
      end

      context 'with a new Group' do
        let(:post_params) { { new_group_name: 'GitLab' } }

        it 'creates the Group' do
          expect { subject }.to change { Group.count }.to(1)
        end
      end
    end

    context 'on failure' do
      let(:apply_trial_result) { false }

      it { is_expected.to render_template(:select) }
      it 'does not call the record conversion method for the experiments' do
        expect(controller).not_to receive(:record_experiment_conversion_event).with(:remove_known_trial_form_fields)
        expect(controller).not_to receive(:record_experiment_conversion_event).with(:trimmed_skip_trial_copy)
        expect(controller).not_to receive(:record_experiment_conversion_event).with(:trial_registration_with_social_signin)

        subject
      end

      context 'with a new Group' do
        let(:post_params) { { new_group_name: 'admin' } }

        it { is_expected.to render_template(:select) }

        it 'does not create the Group' do
          expect { subject }.not_to change { Group.count }.from(0)
        end
      end
    end

    it "calls the ApplyTrialService with correct parameters" do
      gl_com_params = { gitlab_com_trial: true, sync_to_gl: true }
      post_params = {
        namespace_id: namespace.id.to_s,
        trial_entity: 'company',
        glm_source: 'source',
        glm_content: 'content'
      }
      apply_trial_params = {
        uid: user.id,
        trial_user:  ActionController::Parameters.new(post_params).permit(:namespace_id, :trial_entity, :glm_source, :glm_content).merge(gl_com_params)
      }

      expect_next_instance_of(GitlabSubscriptions::ApplyTrialService) do |service|
        expect(service).to receive(:execute).with(apply_trial_params).and_return({ success: true })
      end

      post :apply, params: post_params
    end
  end

  describe 'confirm email warning' do
    before do
      get :new
    end

    RSpec::Matchers.define :set_confirm_warning_for do |email|
      match do |response|
        expect(response).to set_flash.now[:warning].to include("Please check your email (#{email}) to verify that you own this address and unlock the power of CI/CD.")
      end
    end

    context 'with an unconfirmed email address present' do
      let(:user) { create(:user, confirmed_at: nil, unconfirmed_email: 'unconfirmed@gitlab.com') }

      before do
        sign_in(user)
      end

      it { is_expected.not_to set_confirm_warning_for(user.unconfirmed_email) }
    end

    context 'without an unconfirmed email address present' do
      let(:user) { create(:user, confirmed_at: nil) }

      it { is_expected.not_to set_confirm_warning_for(user.email) }
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TrialsController do
  let_it_be(:user) { create(:user, email_opted_in: true) }

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
    subject do
      get :select
      response
    end

    it_behaves_like 'an authenticated endpoint'
    it_behaves_like 'a dot-com only feature'
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
end

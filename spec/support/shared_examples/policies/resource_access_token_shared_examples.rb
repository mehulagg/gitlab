# frozen_string_literal: true

RSpec.shared_examples 'Self-managed Core resource access tokens' do
  before do
    allow(::Gitlab).to receive(:com?).and_return(false)
  end

  context 'create resource access tokens' do
    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:create_resource_access_tokens) }
    end

    context 'with developer' do
      let(:current_user) { developer }

      it { is_expected.not_to be_allowed(:create_resource_access_tokens) }
    end

    context 'when resource access tokens are not available' do
      let(:current_user) { owner }
      let(:group) { create(:group) }
      let(:project) { create(:project, group: group) }

      before do
        group.namespace_settings.update_column(:resource_access_token_creation_allowed, false)
      end

      it { is_expected.not_to be_allowed(:create_resource_access_tokens) }
    end
  end

  context 'read resource access tokens' do
    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:read_resource_access_tokens) }
    end

    context 'with developer' do
      let(:current_user) { developer }

      it { is_expected.not_to be_allowed(:read_resource_access_tokens) }
    end
  end

  context 'destroy resource access tokens' do
    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:destroy_resource_access_tokens) }
    end

    context 'with developer' do
      let(:current_user) { developer }

      it { is_expected.not_to be_allowed(:destroy_resource_access_tokens) }
    end
  end
end

RSpec.shared_examples 'GitLab.com Core resource access tokens' do
  before do
    allow(::Gitlab).to receive(:com?).and_return(true)
    stub_ee_application_setting(should_check_namespace_plan: true)
  end

  context 'with owner' do
    let(:current_user) { owner }

    it { is_expected.not_to be_allowed(:create_resource_access_tokens) }
  end
end

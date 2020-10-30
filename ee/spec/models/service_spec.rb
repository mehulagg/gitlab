# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Service do
  describe '.project_specific_services_names' do
    before do
      allow(::Gitlab).to receive(:dev_env_or_com?).and_return(dev_env_or_com)
    end

    context 'when not on gitlab.com and not in development environment' do
      let(:dev_env_or_com) { false }

      it { expect(described_class.project_specific_services_names).to contain_exactly('github', 'jenkins') }
    end

    context 'when on gitlab.com or in dev environment' do
      let(:dev_env_or_com) { true }

      it { expect(described_class.project_specific_services_names).to contain_exactly('github', 'gitlab_slack_application', 'jenkins') }
    end
  end
end

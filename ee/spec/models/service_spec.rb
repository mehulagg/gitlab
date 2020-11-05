# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Service do
  describe 'Available services' do
    let(:ee_services) do
      %w[
        github
        jenkins
      ]
    end

    it { expect(described_class.available_services_names).to include(*ee_services) }
  end

  describe '.project_specific_services_names' do
    before do
      allow(::Gitlab).to receive(:dev_env_or_com?).and_return(dev_env_or_com)
    end

    context 'when not on gitlab.com and not in development environment' do
      let(:dev_env_or_com) { false }

      it { expect(described_class.project_specific_services_names).to eq([]) }
    end

    context 'when on gitlab.com or in dev environment' do
      let(:dev_env_or_com) { true }

      it { expect(described_class.project_specific_services_names).to eq(%w[gitlab_slack_application]) }
    end
  end
end

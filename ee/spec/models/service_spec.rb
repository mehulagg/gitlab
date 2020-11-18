# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Service do
  let(:ee_project_services) do
    %w[
      github
      jenkins
    ]
  end

  describe '.available_services_names' do
    it { expect(described_class.available_services_names).to include(*ee_project_services) }
  end

  describe '.project_specific_services_names' do
    before do
      allow(::Gitlab).to receive(:com?).and_return(com)
    end

    context 'when not on gitlab.com' do
      let(:com) { false }

      it { expect(described_class.project_specific_services_names).to match_array(ee_project_services) }
    end

    context 'when on gitlab.com' do
      let(:com) { true }

      it { expect(described_class.project_specific_services_names).to match_array(ee_project_services + ['gitlab_slack_application']) }
    end
  end
end

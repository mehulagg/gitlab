# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Autocomplete::VulnerabilitiesFinder do
  describe '#execute' do
    let(:vulnerability) { create(:vulnerability) }
    let(:project) { vulnerability.project }
    let(:user) { create(:user) }

    subject { described_class.new(user, project).execute }

    context 'when user does not have access to project' do
      it { is_expected.to be_empty }
    end

    context 'when user does has access to project' do
      before do
        project.add_developer(user)
      end

      context 'when security dashboards are not enabled' do
        it { is_expected.to be_empty }
      end

      context 'when security dashboards are enabled' do
        before do
          stub_licensed_features(security_dashboard: true)
        end

        it { is_expected.to include(vulnerability) }
      end
    end
  end
end

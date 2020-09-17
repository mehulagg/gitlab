# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Autocomplete::VulnerabilitiesFinder do
  describe '#execute' do
    let!(:group) { create(:group) }
    let!(:project) { create(:project, group: group) }
    let!(:vulnerability) { create(:vulnerability, project: project) }

    let_it_be(:user) { create(:user) }

    subject { described_class.new(user, vulnerable).execute }

    context 'when vulnerable is project' do
      let(:vulnerable) { project }

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

    context 'when vulnerable is group' do
      let(:vulnerable) { project }

      context 'when user does not have access to group' do
        it { is_expected.to be_empty }
      end

      context 'when user does has access to group' do
        before do
          group.add_developer(user)
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
end

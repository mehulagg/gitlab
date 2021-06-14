# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EnvironmentEntity do
  let(:user) { create(:user) }
  let(:environment) { create(:environment) }
  let(:project) { create(:project) }

  let(:entity) do
    described_class.new(environment, request: double(current_user: user, project: project))
  end

  describe '#as_json' do
    subject { entity.as_json }

    context 'with alert' do
      let!(:environment) { create(:environment, project: project) }
      let!(:prometheus_alert) { create(:prometheus_alert, project: project, environment: environment) }
      let!(:alert) { create(:alert_management_alert, :triggered, :prometheus, project: project, environment: environment, prometheus_alert: prometheus_alert) }

      before do
        stub_licensed_features(environment_alerts: true)
      end

      it 'exposes active alert flag' do
        project.add_maintainer(user)

        expect(subject[:has_opened_alert]).to eq(true)
      end

      context 'when user does not have permission to read alert' do
        it 'does not expose active alert flag' do
          project.add_reporter(user)

          expect(subject[:has_opened_alert]).to be_nil
        end
      end

      context 'when license is insufficient' do
        before do
          stub_licensed_features(environment_alerts: false)
        end

        it 'does not expose active alert flag' do
          project.add_maintainer(user)

          expect(subject[:has_opened_alert]).to be_nil
        end
      end
    end

    context 'when environment has a review app' do
      let_it_be(:group) { create(:group) }
      let_it_be(:project) { create(:project, :repository, group: group) }

      let(:environment) { create(:environment, :with_review_app, ref: 'development', project: project) }

      before do
        project.repository.add_branch(user, 'development', project.commit.id)
      end

      describe '#can_stop' do
        subject { entity.as_json[:can_stop] }

        it_behaves_like 'protected environments access'
      end

      describe '#terminal_path' do
        before do
          allow(environment).to receive(:has_terminals?).and_return(true)
        end

        subject { entity.as_json.include?(:terminal_path) }

        it_behaves_like 'protected environments access', developer_access: false
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EnvironmentsHelper do
  let(:environment) { create(:environment) }
  let(:project) { environment.project }
  let(:user) { create(:user) }

  describe '#metrics_data' do
    before do
      allow(helper).to receive(:can?).and_return(false)
    end

    subject { helper.metrics_data(project, environment) }

    context 'user has all accesses' do
      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(helper).to receive(:can?)
          .with(user, :read_prometheus_alerts, project)
          .and_return(true)
        allow(helper).to receive(:can?)
          .with(user, :admin_project, project)
          .and_return(true)
        allow(helper).to receive(:can?)
          .with(user, :read_pod_logs, project)
          .and_return(true)
      end

      it 'returns additional configuration' do
        expect(subject).to include(
          'logs_path' => project_logs_path(project, environment_name: environment.name)
        )
      end
    end

    context 'user does not have access to pod logs' do
      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(helper).to receive(:can?)
                           .with(user, :read_prometheus_alerts, project)
                           .and_return(true)
        allow(helper).to receive(:can?)
                           .with(user, :admin_project, project)
                           .and_return(true)
        allow(helper).to receive(:can?)
                           .with(user, :read_pod_logs, project)
                           .and_return(false)
      end

      it 'returns additional configuration' do
        expect(subject.keys).not_to include('logs_path')
      end
    end
  end

  describe '#environment_logs_data' do
    subject { helper.environment_logs_data(project, environment) }

    it 'returns environment parameters data' do
      expect(subject).to include(
        "environment_name": environment.name,
        "environments_path": api_v4_projects_environments_path(id: project.id)
      )
    end

    it 'returns parameters for forming the pod logs API URL' do
      expect(subject).to include(
        "environment_id": environment.id
      )
    end
  end
end

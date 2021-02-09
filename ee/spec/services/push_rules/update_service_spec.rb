# fronzen_string_literal: true

require 'spec_helper'

RSpec.describe PushRules::UpdateService, '#execute' do
  let_it_be_with_reload(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let(:params) { { max_file_size: 28 } }

  subject(:service) { described_class.new(container: project, current_user: user, params: params) }

  shared_examples 'a failed update' do
    let(:params) { { max_file_size: -28 } }

    it 'responds with an error service response', :aggregate_failures do
      response = subject.execute

      expect(response).to be_error
      expect(response.message).to eq('Push rule update failed')
      expect(response.payload).to eq(project.push_rule)
    end
  end

  context 'with existing push rule' do
    let_it_be(:push_rule) { create(:push_rule, project: project) }

    it 'updates existing push rule' do
      expect { subject.execute }
        .to change { PushRule.count }.by(0)
        .and change { push_rule.reload.max_file_size }.to(28)
    end

    it 'responds with a successful service response', :aggregate_failures do
      response = subject.execute

      expect(response).to be_success
      expect(response.payload).to eq(push_rule)
    end

    it_behaves_like 'a failed update'
  end

  context 'without existing push rule' do
    it 'creates a new push rule' do
      expect { subject.execute }
        .to change { PushRule.count }.by(1)

      expect(project.push_rule.max_file_size).to eq(28)
    end

    it 'responds with a successful service response', :aggregate_failures do
      response = subject.execute

      expect(response).to be_success
      expect(response.payload).to eq(project.push_rule)
    end

    it_behaves_like 'a failed update'
  end
end

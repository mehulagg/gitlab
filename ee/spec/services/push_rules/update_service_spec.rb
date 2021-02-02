# fronzen_string_literal: true

require 'spec_helper'

RSpec.describe PushRules::UpdateService, '#execute' do
  let_it_be_with_reload(:group) { create(:group) }
  let_it_be(:user) { create(:user) }
  let(:params) { { max_file_size: 28 } }

  subject(:service) { described_class.new(container: group, current_user: user, params: params) }

  context 'with existing push rule' do
    let_it_be(:existing_push_rule) { create(:push_rule) }

    before do
      group.update!(push_rule: existing_push_rule)
    end

    it 'updates existing push rule' do
      expect { subject.execute }
        .to change { PushRule.count }.by(0)
        .and change { existing_push_rule.reload.max_file_size }.to(28)
    end

    it 'responds with a successful service response', :aggregate_failures do
      response = subject.execute

      expect(response).to be_success
      expect(response.payload.max_file_size).to eq(28)
    end
  end

  context 'without existing push rule' do
    it 'creates a new push rule' do
      expect { subject.execute }
        .to change { group.push_rule }
        .from(nil).to(be_instance_of(PushRule))
    end

    it 'responds with a successful service response', :aggregate_failures do
      response = subject.execute

      expect(response).to be_success
      expect(response.payload.max_file_size).to eq(28)
    end
  end

  context 'when saving fails' do
    let(:params) { { max_file_size: -28 } }

    it 'responds with an error service response', :aggregate_failures do
      response = subject.execute

      expect(response).to be_error
      expect(response.message).to eq(max_file_size: ['must be greater than or equal to 0'])
    end
  end
end

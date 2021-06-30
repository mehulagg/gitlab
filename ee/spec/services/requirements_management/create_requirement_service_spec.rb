# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequirementsManagement::CreateRequirementService do
  let_it_be(:project) { create(:project)}
  let_it_be(:user) { create(:user) }
  let_it_be(:other_user) { create(:user) }

  let(:params) { { title: 'foo', author_id: other_user.id, created_at: 2.days.ago } }

  subject { described_class.new(project: project, current_user: user, params: params).execute }

  describe '#execute' do
    before do
      stub_licensed_features(requirements: true)
    end

    context 'when user can create requirements' do
      before do
        project.add_reporter(user)
      end

      it 'creates new requirement' do
        expect { subject }.to change { RequirementsManagement::Requirement.count }.by(1)
      end

      it 'uses only permitted params' do
        requirement = subject

        expect(requirement).to be_persisted
        expect(requirement.title).to eq(params[:title])
        expect(requirement.state).to eq('opened')
        expect(requirement.created_at).not_to eq(params[:created_at])
        expect(requirement.author_id).not_to eq(params[:author_id])
      end
    end

    context 'when user is not allowed to create requirements' do
      it 'raises an exception' do
        expect { subject }.to raise_exception(Gitlab::Access::AccessDeniedError)
      end
    end
  end
end

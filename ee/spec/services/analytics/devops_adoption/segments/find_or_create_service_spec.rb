# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::FindOrCreateService do
  include AdminModeHelper

  let_it_be(:admin) { create(:user, :admin) }
  let_it_be(:group) { create(:group) }

  let(:params) { { namespace: group } }
  let(:segment) { subject.payload[:segment] }

  subject { described_class.new(params: params, current_user: admin).execute }

  before do
    enable_admin_mode!(admin)
  end

  context 'for admins' do
    context 'when segment for given namespace already exists' do
      let!(:segment) { create :devops_adoption_segment, namespace: group }

      it 'returns existing segment' do
        expect(subject.payload.fetch(:segment)).to eq(segment)
      end
    end

    context 'when segment for given namespace does not exist' do
      it 'calls for segment creation' do
        expect_next_instance_of(Analytics::DevopsAdoption::Segments::CreateService, current_user: admin, params: {namespace: group}) do |instance|
          expect(instance).to receive(:execute).and_return('create_response')
        end

        expect(subject).to eq 'create_response'
      end
    end
  end

  context 'for non-admins' do
    let(:user) { build(:user) }

    subject { described_class.new(params: params, current_user: user).execute }

    it 'returns forbidden error' do
      expect(subject).to be_error
      expect(subject.message).to eq('Forbidden')
    end
  end
end

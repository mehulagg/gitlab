# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::FindOrCreateService do
  include AdminModeHelper

  let_it_be(:user) { create(:user, :admin) }
  let_it_be(:group) { create(:group) }

  let(:params) { { namespace: group } }
  let(:segment) { subject.payload[:segment] }

  subject { described_class.new(params: params, current_user: user).execute }

  before do
    enable_admin_mode!(user)
  end

  context 'for admins' do
    context 'when segment for given namespace already exists' do
      let!(:segment) { create :devops_adoption_segment, namespace: group }

      it 'returns existing segment' do
        expect do
          subject
        end.not_to change { Analytics::DevopsAdoption::Segment.count }

        expect(subject.payload.fetch(:segment)).to eq(segment)
      end
    end

    context 'when segment for given namespace does not exist' do
      it 'calls for segment creation' do
        expect_next_instance_of(Analytics::DevopsAdoption::Segments::CreateService, current_user: user, params: { namespace: group }) do |instance|
          expect(instance).to receive(:execute).and_return('create_response')
        end

        expect(subject).to eq 'create_response'
      end
    end
  end

  context 'for non-admins' do
    let_it_be(:user) { build(:user) }

    it 'returns forbidden error' do
      expect do
        subject
      end.to raise_error(Analytics::DevopsAdoption::Segments::AuthorizationError)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::BulkFindOrCreateService do
  include AdminModeHelper

  let_it_be(:user) { create(:user, :admin) }
  let_it_be(:group) { create(:group) }
  let_it_be(:group2) { create(:group) }

  let(:params) { { namespaces: [group, group2] } }
  let!(:segment) { create :devops_adoption_segment, namespace: group }

  subject { described_class.new(params: params, current_user: user).execute }

  before do
    enable_admin_mode!(user)
  end

  context 'for admins' do
    it 'returns existing segments for namespaces and creates new one if none exists' do
      expect do
        subject
      end.to change { ::Analytics::DevopsAdoption::Segment.count }.by(1)
      expect(subject.payload.fetch(:segments)).to include(segment)
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

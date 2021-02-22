# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::BulkDeleteService do
  include AdminModeHelper

  let_it_be(:user) { create(:user, :admin) }
  let_it_be(:group) { create(:group) }
  let(:segment) { create(:devops_adoption_segment, namespace: group) }
  let(:segment2) { create(:devops_adoption_segment) }

  subject { described_class.new(segments: [segment, segment2], current_user: user).execute }

  before do
    enable_admin_mode!(user)
  end

  it 'deletes the segments' do
    expect(subject).to be_success
    expect(segment).not_to be_persisted
    expect(segment2).not_to be_persisted
  end

  context 'when deletion fails' do
    it 'keeps records and returns error response' do
      expect(segment).to receive(:destroy).and_raise(ActiveRecord::RecordNotDestroyed)

      expect(subject).to be_error
      expect(subject.message).to eq('Devops Adoption Segment deletion error')
      expect(segment).to be_persisted
      expect(segment2).to be_persisted
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

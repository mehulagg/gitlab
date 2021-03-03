# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::DeleteService do
  include AdminModeHelper

  let_it_be(:user) { create(:user, :admin) }
  let_it_be(:group) { create(:group) }
  let(:segment) { create(:devops_adoption_segment, namespace: group) }

  subject { described_class.new(segment: segment, current_user: user).execute }

  before do
    enable_admin_mode!(user)
  end

  it 'deletes the segment' do
    expect(subject).to be_success
    expect(segment).not_to be_persisted
  end

  context 'when deletion fails' do
    it 'returns error response' do
      expect(segment).to receive(:destroy).and_raise(ActiveRecord::RecordNotDestroyed)

      expect(subject).to be_error
      expect(subject.message).to eq('Devops Adoption Segment deletion error')
    end
  end

  context 'when the user is not admin' do
    let(:user) { build(:user) }

    it 'returns error response' do
      expect(subject).to be_error
      expect(subject.message).to eq('Forbidden')
    end
  end
end

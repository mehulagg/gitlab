# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Segments::BulkDeleteService do
  include AdminModeHelper

  let_it_be(:group) { create(:group) }
  let_it_be(:admin) { create(:user, :admin) }

  let(:segment) { create(:devops_adoption_segment, namespace: group) }
  let(:segment2) { create(:devops_adoption_segment) }
  let(:current_user) { admin }

  subject(:response) { described_class.new(segments: [segment, segment2], current_user: current_user).execute }

  before do
    enable_admin_mode!(admin)
    stub_licensed_features(group_level_devops_adoption: true, instance_level_devops_adoption: true)
  end

  it 'deletes the segments' do
    expect(response).to be_success
    expect(segment).not_to be_persisted
    expect(segment2).not_to be_persisted
  end

  context 'when deletion fails' do
    it 'keeps records and returns error response' do
      expect(segment).to receive(:destroy).and_raise(ActiveRecord::RecordNotDestroyed)

      expect(response).to be_error
      expect(response.message).to eq('DevOps Adoption Segment deletion error')
      expect(segment).to be_persisted
      expect(segment2).to be_persisted
    end
  end

  it 'authorizes for manage_devops_adoption' do
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_segments, group)
                           .at_least(1)
                           .and_return(true)
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_segments, segment.display_namespace)
                           .at_least(1)
                           .and_return(true)
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_segments, segment2.namespace)
                           .at_least(1)
                           .and_return(true)
    expect(::Ability).to receive(:allowed?)
                           .with(current_user, :manage_devops_adoption_segments, segment2.display_namespace)
                           .at_least(1)
                           .and_return(true)

    response
  end
end

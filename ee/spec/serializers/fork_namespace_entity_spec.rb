# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ForkNamespaceEntity do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  let(:namespace) { create(:group_with_deletion_schedule, :with_avatar, description: 'test', marked_for_deletion_on: 1.day.ago) }
  let(:memberships) do
    user.members.index_by(&:source_id)
  end

  let(:entity) { described_class.new(namespace, current_user: user, project: project, memberships: memberships) }

  subject(:json) { entity.as_json }

  before do
    stub_licensed_features(adjourned_deletion_for_projects_and_groups: true)
  end

  it 'exposes marked_for_deletion state' do
    expect(json[:marked_for_deletion]).to eq true
  end
end

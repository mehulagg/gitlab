# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectAuthorization do
  describe '.visible_to_user_and_access_level' do
    let(:user) { create(:user) }
    let(:project1) { create(:project) }
    let(:project2) { create(:project) }

    it 'returns the records for given user that have at least the given access' do
      described_class.create!(user: user, project: project2, access_level: Gitlab::Access::DEVELOPER)
      maintainer_access = described_class.create!(user: user, project: project1, access_level: Gitlab::Access::MAINTAINER)

      authorizations = described_class.visible_to_user_and_access_level(user, Gitlab::Access::MAINTAINER)

      expect(authorizations.count).to eq(1)
      expect(authorizations[0].user_id).to eq(maintainer_access.user_id)
      expect(authorizations[0].project_id).to eq(maintainer_access.project_id)
      expect(authorizations[0].access_level).to eq(maintainer_access.access_level)
    end
  end
end

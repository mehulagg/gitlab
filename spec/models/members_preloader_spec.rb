# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MembersPreloader do
  describe '#preload_all' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    def created_by_with_preload(members)
      MembersPreloader.new(members).preload_all
      MembersPresenter.new(members, current_user: nil).each do |member|
        next unless member.created_by.present?

        UserEntity.represent(member.created_by, only: [:name, :web_url])
      end
    end

    it 'preloads created_by to avoid N+1 queries in MembersPresenter', :use_sql_query_cache do
      member = create(:group_member, group: group, created_by: user)
      control = ActiveRecord::QueryRecorder.new { created_by_with_preload([member]) }

      members = create_list(:group_member, 3, group: group, created_by: user)

      expect { created_by_with_preload(members) }.not_to exceed_query_limit(control)
    end
  end
end

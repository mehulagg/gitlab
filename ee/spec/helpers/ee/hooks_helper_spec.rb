# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HooksHelper do
  let(:group) { create(:group) }
  let(:group_hook) { create(:group_hook, group: group) }
  let(:trigger) { 'push_events' }

  describe '#link_to_test_hook' do
    it 'returns group namespaced link' do
      expect(helper.link_to_test_hook(group_hook, trigger))
        .to include("href=\"#{test_group_hook_path(group, group_hook, trigger: trigger)}\"")
    end
  end
end

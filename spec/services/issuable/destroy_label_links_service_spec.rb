# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Issuable::DestroyLabelLinksService do
  describe '#execute' do
    let_it_be(:target) { create(:merge_request) }
    let_it_be(:label_link_1) { create(:label_link, target: target) }
    let_it_be(:label_link_2) { create(:label_link, target: target) }

    def execute
      described_class.new(target.id, target.class.name).execute
    end

    it 'deletes label links for specified target ID and type' do
      control_count = ActiveRecord::QueryRecorder.new { execute }.count

      # Create more label links for the target
      create(:label_link, target: target)
      create(:label_link, target: target)

      expect { execute }.not_to exceed_query_limit(control_count)
      expect(target.reload.label_links.count).to eq(0)
    end
  end
end

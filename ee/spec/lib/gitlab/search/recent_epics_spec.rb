# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Search::RecentEpics do
  let(:parent_type) { :group }

  def create_item(content:, parent:)
    create(:epic, title: content, group: parent)
  end

  before do
    stub_licensed_features(epics: true)
  end

  it_behaves_like 'search recent items'
end

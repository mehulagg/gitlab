# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/nav/sidebar/_group' do
  let(:group) { create(:group) }

  before do
    assign(:group, group)
  end

  it_behaves_like 'has nav sidebar'
  it_behaves_like 'includes snowplow attributes', 'render', 'groups_side_navigation', 'groups_side_navigation'
end

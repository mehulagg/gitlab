# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProductivityAnalyticsMergeRequestEntity do
  subject { described_class.represent(merge_request).as_json.with_indifferent_access }

  let(:merge_request) { create(:merge_request) }

  before do
    ProductivityAnalytics::METRIC_TYPES.each.with_index do |type, i|
      allow(merge_request).to receive(type).and_return(i)
    end
  end

  it 'exposes all additional metrics' do
    expect(subject.keys).to include(*ProductivityAnalytics::METRIC_TYPES)
  end

  it 'exposes author_avatar_url' do
    expect(subject[:author_avatar_url]).to eq merge_request.author.avatar_url
  end

  it 'exposes merge_request_url' do
    expect(subject[:merge_request_url])
      .to eq Gitlab::Routing.url_helpers.project_merge_request_url(merge_request.project, merge_request)
  end
end

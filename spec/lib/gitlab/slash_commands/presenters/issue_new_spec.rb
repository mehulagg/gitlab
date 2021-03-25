# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SlashCommands::Presenters::IssueNew do
  let(:project) { create(:project) }
  let(:issue) { create(:issue, project: project) }
  let(:text) { subject[:text].first }

  subject { described_class.new(issue).present }

  it { is_expected.to be_a(Hash) }

  it 'shows the issue' do
    expect(subject[:response_type]).to be(:in_channel)
    expect(subject).to have_key(:text)
    expect(subject[:text]).to include(issue.to_reference)
  end
end

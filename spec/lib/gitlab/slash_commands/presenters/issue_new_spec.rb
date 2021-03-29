# frozen_string_literal: true

require 'spec_helper'
include Rails.application.routes.url_helpers

RSpec.describe Gitlab::SlashCommands::Presenters::IssueNew do
  let(:project) { create(:project) }
  let(:issue) { create(:issue, project: project) }
  let(:text) { subject[:text].first }

  subject { described_class.new(issue).present }

  it { is_expected.to be_a(Hash) }

  it 'shows the issue' do
    expect(subject[:response_type]).to be(:in_channel)
    expect(subject).to have_key(:text)
    expect(subject[:text]).to eq("I created an issue on <#{url_for(issue.author)}|#{issue.author.to_reference}>'s behalf: *<#{project_issue_url(issue.project, issue)}|#{issue.to_reference}>* in <#{project.web_url}|#{project.full_name}>")
  end
end

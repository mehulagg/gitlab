# frozen_string_literal: true

require 'spec_helper'
require 'email_spec'

RSpec.describe Emails::MergeRequests do
  include EmailSpec::Matchers

  include_context 'gitlab email notification'

  let_it_be(:current_user) { create(:user) }
  let_it_be(:assignee, reload: true) { create(:user, email: 'assignee@example.com', name: 'John Doe') }
  let_it_be(:reviewer, reload: true) { create(:user, email: 'reviewer@example.com', name: 'Jane Doe') }
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:merge_request) do
    create(:merge_request, source_project: project,
                           target_project: project,
                           author: current_user,
                           assignees: [assignee],
                           reviewers: [reviewer],
                           description: 'Awesome description')
  end

  let(:recipient) { assignee }

  describe '#merge_request_unmergeable_email' do
    subject { Notify.merge_request_unmergeable_email(recipient.id, merge_request.id) }

    it_behaves_like 'a multiple recipients email'
    it_behaves_like 'an answer to an existing thread with reply-by-email enabled' do
      let(:model) { merge_request }
    end

    it_behaves_like 'it should show Gmail Actions View Merge request link'
    it_behaves_like 'an unsubscribeable thread'
    it_behaves_like 'appearance header and footer enabled'
    it_behaves_like 'appearance header and footer not enabled'

    it 'is sent as the merge request author' do
      sender = subject.header[:from].addrs[0]
      expect(sender.display_name).to eq(merge_request.author.name)
      expect(sender.address).to eq(gitlab_sender)
    end

    it 'has the correct subject and body' do
      aggregate_failures do
        is_expected.to have_referable_subject(merge_request, reply: true)
        is_expected.to have_body_text(project_merge_request_path(project, merge_request))
        is_expected.to have_body_text('due to conflict.')
        is_expected.to have_link(merge_request.to_reference, href: project_merge_request_url(merge_request.target_project, merge_request))

        expect(subject.text_part).to have_content(assignee.name)
        expect(subject.text_part).to have_content(reviewer.name)
      end
    end
  end


  describe "#merge_when_pipeline_succeeds_email" do
    let(:title) { "Merge request #{merge_request.to_reference} was scheduled to merge after pipeline succeeds by #{current_user.name}" }

    subject { Notify.merge_when_pipeline_succeeds_email(recipient.id, merge_request.id, current_user.id) }

    it "has required details" do
      aggregate_failures do
        expect(subject).to have_content title
        expect(subject).to have_content merge_request.to_reference
        expect(subject).to have_content current_user.name
        expect(subject.html_part).to have_content(assignee.name)
        expect(subject.text_part).to have_content(assignee.name)
        expect(subject.html_part).to have_content(reviewer.name)
        expect(subject.text_part).to have_content(reviewer.name)
      end
    end
  end

  describe '#merge_requests_csv_email' do
    let(:merge_requests) { create_list(:merge_request, 10) }
    let(:export_status) do
      {
        rows_expected: 10,
        rows_written: 10,
        truncated: false
      }
    end

    let(:csv_data) { MergeRequests::ExportCsvService.new(MergeRequest.all, project).csv_data }

    subject { Notify.merge_requests_csv_email(recipient, project, csv_data, export_status) }

    it { expect(subject.subject).to eq("#{project.name} | Exported merge requests") }
    it { expect(subject.to).to contain_exactly(recipient.notification_email_for(project.group)) }
    it { expect(subject.html_part).to have_content("Your CSV export of 10 merge requests from project") }
    it { expect(subject.text_part).to have_content("Your CSV export of 10 merge requests from project") }

    context 'when truncated' do
      let(:export_status) do
        {
            rows_expected: 10,
            rows_written: 10,
            truncated: true
        }
      end

      it { expect(subject).to have_content('attachment has been truncated to avoid exceeding the maximum allowed attachment size of 15 MB.') }
    end
  end
end

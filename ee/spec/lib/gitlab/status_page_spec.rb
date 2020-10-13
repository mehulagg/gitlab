# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::StatusPage do
  let(:project) { instance_double(Project) }
  let(:user) { instance_double(User) }
  let(:triggered_by) { instance_double(Issue) }

  describe '.trigger_publish' do
    subject { described_class.trigger_publish(project, user, triggered_by) }

    it 'delegates to TriggerPublishService' do
      expect_next_instance_of(StatusPage::TriggerPublishService,
                              project, user, triggered_by, action: :update) do |service|
        expect(service).to receive(:execute)
      end

      subject
    end
  end

  describe '.mark_for_publication' do
    subject { described_class.mark_for_publication(project, user, triggered_by) }

    it 'delegates to PublishIssueService' do
      expect_next_instance_of(StatusPage::MarkForPublicationService,
                              project, user, triggered_by) do |service|
        expect(service).to receive(:execute)
      end

      subject
    end
  end
end

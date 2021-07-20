# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEvents::ReleaseAssociateMilestoneAuditEventService do
  describe '#security_event' do
    context 'with no milestones' do
      include_examples 'logs the release audit event' do
        let(:release) { create(:release, project: entity) }
        let(:custom_message) { "Milestones associated with release changed to [none]" }
      end
    end

    context "with one milestone" do
      include_examples 'logs the release audit event' do
        let(:release) { create(:release, :with_milestones, milestones_count: 1, project: entity) }
        let(:custom_message) { "Milestones associated with release changed to #{Milestone.first.title}" }
      end
    end

    context "with multiple milestones" do
      include_examples 'logs the release audit event' do
        let(:release) { create(:release, :with_milestones, milestones_count: 2, project: entity) }
        let(:custom_message) { "Milestones associated with release changed to #{Milestone.first.title}, #{Milestone.second.title}" }
      end
    end
  end
end

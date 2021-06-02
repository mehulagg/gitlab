# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEvents::ReleaseUpdatedAuditEventService do
  describe '#security_event' do
    include_examples 'logs the release audit event' do
      let(:release) { create(:release, project: entity) }
      let(:custom_message) { "Updated Release #{release.tag}" }
    end
  end
end

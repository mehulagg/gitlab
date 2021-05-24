# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEvents::ReleaseArtifactsDownloadedAuditEventService do
  describe '#security_event' do
    include_examples 'logs the release audit event' do
      let(:release) { create(:release, project: entity) }
      let(:custom_message) { 'Repository External Resource Download Started' }
    end
  end
end

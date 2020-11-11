# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshot, type: :model do
  it { is_expected.to belong_to(:segment) }

  it { is_expected.to validate_presence_of(:segment) }
  it { is_expected.to validate_presence_of(:recorded_at) }
  it { is_expected.to validate_presence_of(:issue_opened) }
  it { is_expected.to validate_presence_of(:merge_request_opened) }
  it { is_expected.to validate_presence_of(:merge_request_approved) }
  it { is_expected.to validate_presence_of(:runner_configured) }
  it { is_expected.to validate_presence_of(:pipeline_succeeded) }
  it { is_expected.to validate_presence_of(:deploy_succeeded) }
  it { is_expected.to validate_presence_of(:security_scan_succeeded) }
end

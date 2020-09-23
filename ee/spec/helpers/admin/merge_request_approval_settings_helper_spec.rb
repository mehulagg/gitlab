# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::MergeRequestApprovalSettingsHelper do
  describe '#show_compliance_merge_request_approval_settings?' do
    using RSpec::Parameterized::TableSyntax

    subject { helper.show_compliance_merge_request_approval_settings? }

    where(:licensed, :result) do
      true  | true
      false | false
    end

    with_them do
      before do
        stub_licensed_features(admin_merge_request_approvers_rules: licensed)
      end

      it { is_expected.to eq(result) }
    end
  end
end

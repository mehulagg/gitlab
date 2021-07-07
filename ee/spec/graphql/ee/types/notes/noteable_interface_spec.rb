# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Types::Notes::NoteableInterface do
  let(:extended_class) { Types::Notes::NoteableInterface }

  describe ".resolve_type" do
    it 'knows the correct type for objects' do
      expect(extended_class.resolve_type(build(:issue), {})).to eq(Types::IssueType)
      expect(extended_class.resolve_type(build(:merge_request), {})).to eq(Types::MergeRequestType)
      expect(extended_class.resolve_type(build(:design), {})).to eq(Types::DesignManagement::DesignType)
      expect(extended_class.resolve_type(build(:alert_management_alert), {})).to eq(Types::AlertManagement::AlertType)
      expect(extended_class.resolve_type(build(:vulnerability), {})).to eq(Types::VulnerabilityType)
    end
  end
end

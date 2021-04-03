# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ResourceStateEvent do
  subject { build(:resource_state_event) }

  it { is_expected.to belong_to(:epic) }

  describe 'validations' do
    describe 'Issuable validation' do
      it 'is valid if only epic is set' do
        subject.attributes = { epic: build_stubbed(:epic), issue: nil, merge_request: nil }

        expect(subject).to be_valid
      end

      it 'is invalid if an epic and an issue is set' do
        subject.attributes = { epic: build_stubbed(:epic), issue: build_stubbed(:issue), merge_request: nil }

        expect(subject).not_to be_valid
      end
    end
  end
end

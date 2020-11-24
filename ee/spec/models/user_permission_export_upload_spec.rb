# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserPermissionExportUpload, type: :model do
  let_it_be(:upload) { build(:user_permission_export_upload) }

  subject { upload }

  describe 'associations' do
    it { is_expected.to belong_to(:user).conditions(admin: true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }

    context 'when status is finished' do
      before do
        allow(upload).to receive(:finished?).and_return true
      end

      it 'validates file presence' do
        expect(upload).not_to be_valid
        expect(upload.errors.full_messages).to include("File can't be blank")
      end
    end
  end

  describe 'state transitions' do
    using RSpec::Parameterized::TableSyntax

    where(:status, :can_start, :can_finish, :can_fail) do
      0 | true  | false | true
      1 | false | true  | true
      2 | false | false | false
      3 | false | false | false
    end

    with_them do
      it 'adheres to state machine rules', :aggregate_failures do
        upload.status = status

        expect(upload.can_start?).to eq(can_start)
        expect(upload.can_finish?).to eq(can_finish)
        expect(upload.can_failed?).to eq(can_fail)
      end
    end
  end
end

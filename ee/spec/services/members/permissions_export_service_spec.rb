# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Members::PermissionsExportService do
  let(:service) { described_class.new(user) }

  let(:admin) { create(:user, :admin) }
  let(:non_admin) { create(:user) }

  context 'access', :enable_admin_mode do
    using RSpec::Parameterized::TableSyntax

    where(:current_user, :licensed, :result) do
      admin      | true  | true
      admin      | false | false
      non_admin  | true  | false
      non_admin  | false | false
    end

    with_them do
      let(:user) { current_user }

      before do
        stub_licensed_features(export_user_permissions: licensed)
      end

      it do
        expect(service.csv_data.success?).to be result
      end
    end
  end
end

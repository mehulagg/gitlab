# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HealthStatus do
  describe '#supports_health_status?' do
    using RSpec::Parameterized::TableSyntax

    let(:project_with_group) { build_stubbed(:project, group: group, creator: creator) }
    let(:group) { build_stubbed(:group) }
    let(:creator) { build_stubbed(:user) }

    before do
      stub_licensed_features(issuable_health_status: issuable_health_status)
    end

    where(:issuable_type, :issuable_health_status, :supports_health_status) do
      :issue         | true  | true
      :issue         | false | false
      :incident      | true  | false
      :incident      | false | false
      :merge_request | true  | false
      :merge_request | false | false
    end

    with_them do
      let(:issuable) { build_stubbed(issuable_type, project: project_with_group) }

      subject { issuable.supports_health_status? }

      it { is_expected.to eq(supports_health_status) }
    end
  end
end

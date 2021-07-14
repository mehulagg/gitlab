# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ServicePing::PermitDataCategoriesService do
  using RSpec::Parameterized::TableSyntax

  describe '#execute' do
    subject(:permitted_categories) { described_class.new.execute }

    context 'with out current license', :without_license do
      context 'when usage ping setting is set to true' do
        before do
          stub_config_setting(usage_ping_enabled: true)
        end

        it 'returns all categories' do
          expect(permitted_categories).to match_array(%w[Standard Subscription Operational Optional])
        end
      end

      context 'when usage ping setting is set to false' do
        before do
          stub_config_setting(usage_ping_enabled: false)
        end

        it 'returns no categories' do
          expect(permitted_categories).to match_array([])
        end
      end
    end

    context 'with current license' do
      context 'when usage ping setting is set to true' do
        before do
          stub_config_setting(usage_ping_enabled: true)
        end

        context 'and license has operational_metrics_enabled set to true' do
          before do
            # License.current.usage_ping? == true
            create_current_license(operational_metrics_enabled: true)
          end

          it 'returns all categories' do
            expect(permitted_categories).to match_array(%w[Standard Subscription Operational Optional])
          end

          context 'when User.single_user&.requires_usage_stats_consent? is required' do
            before do
              allow(User).to receive(:single_user).and_return(double(:user, requires_usage_stats_consent?: true))
            end

            it 'returns no categories' do
              expect(permitted_categories).to match_array([])
            end
          end
        end

        context 'and license has operational_metrics_enabled set to false' do
          before do
            # License.current.usage_ping? == true
            create_current_license(operational_metrics_enabled: false)
          end

          it 'returns all categories' do
            expect(permitted_categories).to match_array(%w[Standard Subscription Operational Optional])
          end
        end
      end

      context 'when usage ping setting is set to false' do
        before do
          stub_config_setting(usage_ping_enabled: false)
        end

        context 'and license has operational_metrics_enabled set to true' do
          before do
            # License.current.usage_ping? == true
            create_current_license(operational_metrics_enabled: true)
          end

          it 'returns all categories' do
            expect(permitted_categories).to match_array(%w[Standard Subscription Operational])
          end
        end

        context 'and license has operational_metrics_enabled set to false' do
          before do
            # License.current.usage_ping? == true
            create_current_license(operational_metrics_enabled: false)
          end

          it 'returns all categories' do
            expect(permitted_categories).to match_array(%w[])
          end
        end
      end
    end
  end

  describe '#product_intelligence_enabled?' do
    where(:usage_ping_enabled, :customer_service_enabled, :requires_usage_stats_consent, :expected_product_intelligence_enabled) do
      # Customer service enabled
      true  | true  | false | true
      false | true  | true  | false
      false | true  | false | true
      true  | true  | true  | false

      # Customer service disabled
      true  | false | false | true
      true  | false | true  | false
      false | false | false | false
      false | false | true  | false

      # When there is no license it should have same behaviour as ce
      true  | nil | false | true
      false | nil | false | false
      false | nil | true  | false
      true  | nil | true  | false
    end

    with_them do
      before do
        allow(User).to receive(:single_user).and_return(double(:user, requires_usage_stats_consent?: requires_usage_stats_consent))
        stub_config_setting(usage_ping_enabled: usage_ping_enabled)
        create_current_license(operational_metrics_enabled: customer_service_enabled)
      end

      it 'has the correct product_intelligence_enabled?' do
        expect(described_class.new.product_intelligence_enabled?).to eq(expected_product_intelligence_enabled)
      end
    end
  end
end

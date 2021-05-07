# frozen_string_literal: true

RSpec.shared_examples 'a framework registry finder' do |registry_factory|
  include ::EE::GeoHelpers

  # rubocop:disable Rails/SaveBang
  let!(:registry1) { create(registry_factory) }
  let!(:registry2) { create(registry_factory) }
  let!(:registry3) { create(registry_factory) }
  # rubocop:enable Rails/SaveBang

  let(:params) { {} }

  subject(:registries) { described_class.new(user, params).execute }

  describe '#execute' do
    context 'when user cannot read all Geo' do
      let_it_be(:user) { create(:user) }

      it { is_expected.to be_empty }
    end

    context 'when user can read all Geo' do
      let_it_be(:user) { create(:user, :admin) }

      context 'when admin mode is disabled' do
        it { is_expected.to be_empty }
      end

      context 'when admin mode is enabled', :enable_admin_mode do
        context 'with an ids param' do
          let(:params) { { ids: [registry3.id, registry1.id] } }

          it 'returns specified registries' do
            expect(registries.to_a).to contain_exactly(registry1, registry3)
          end
        end

        context 'without an ids param' do
          it 'returns all registries' do
            expect(registries.to_a).to contain_exactly(registry1, registry2, registry3)
          end
        end
      end
    end
  end
end

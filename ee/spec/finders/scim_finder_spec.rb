# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScimFinder do
  let_it_be(:group) { create(:group) }

  let(:unused_params) { double }

  subject(:finder) { described_class.new(group) }

  describe '#search' do
    context 'without a SAML provider' do
      it 'returns an empty scim identity relation' do
        expect(finder.search(unused_params)).to eq ScimIdentity.none
      end
    end

    context 'SCIM/SAML is not enabled' do
      before do
        create(:saml_provider, group: group, enabled: false)
      end

      it 'returns an empty scim identity relation' do
        expect(finder.search(unused_params)).to eq ScimIdentity.none
      end
    end

    context 'with SCIM enabled' do
      let_it_be(:saml_provider) { create(:saml_provider, group: group) }

      context 'with an eq filter' do
        let_it_be(:user) { create(:user, username: 'foo', email: 'bar@example.com') }
        let_it_be(:id) { create(:scim_identity, group: group, user: user) }

        it 'allows identity lookup by id/externalId' do
          expect(finder.search(filter: "id eq #{id.extern_uid}")).to be_a ActiveRecord::Relation
          expect(finder.search(filter: "id eq #{id.extern_uid}").first).to eq id
          expect(finder.search(filter: "externalId eq #{id.extern_uid}").first).to eq id
        end

        it 'allows lookup by userName' do
          expect(finder.search(filter: "userName eq \"#{id.user.username}\"").first).to eq id
        end

        context 'allows lookup by userName' do
          it 'finds user by an email address' do
            expect(finder.search(filter: "userName eq #{id.user.email}").first).to eq id
          end

          it 'finds user by using local part of email address as username' do
            email = "#{id.user.username}@example.com"
            expect(finder.search(filter: "userName eq #{email}").first).to eq id
          end

          it 'finds user by username' do
            expect(finder.search(filter: "userName eq \"#{id.user.username}\"").first).to eq id
          end

          it 'finds user by extern_uid' do
            expect(finder.search(filter: "userName eq \"#{id.extern_uid}\"").first).to eq id
          end
        end
      end

      context 'with no filter' do
        it 'returns all related scim_identities' do
          create_list(:scim_identity, 4, group: group)

          expect(finder.search({}).count).to eq 4
        end
      end

      it 'raises an error if the filter is unsupported' do
        expect { finder.search(filter: 'id ne 1').count }.to raise_error(ScimFinder::UnsupportedFilter)
      end

      it 'raises an error if the attribute path is unsupported' do
        expect { finder.search(filter: 'displayName eq "name"').count }.to raise_error(ScimFinder::UnsupportedFilter)
      end
    end
  end
end

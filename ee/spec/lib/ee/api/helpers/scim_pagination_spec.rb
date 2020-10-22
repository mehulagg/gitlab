# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Helpers::ScimPagination do
  let(:query) { {} }
  let(:pagination_class) { Struct.new(:params).include(described_class) }

  subject(:paginatable) { pagination_class.new(query) }

  describe '#per_page' do
    using RSpec::Parameterized::TableSyntax

    where(:count, :per_page) do
      nil    | Kaminari.config.default_per_page
      ''     | Kaminari.config.default_per_page
      'abc'  | Kaminari.config.default_per_page
      0      | Kaminari.config.default_per_page
      999999 | Kaminari.config.max_per_page
      4      | 4
      '4'    | 4
    end

    with_them do
      it { expect(subject.per_page(count)).to eq(per_page) }
    end
  end

  describe '#scim_paginate' do
    let(:resource) { Identity.all }

    before do
      create_list(:group_saml_identity, 3)
    end

    describe 'without pagination params' do
      it 'returns all results' do
        expect(subject.scim_paginate(resource).count).to eq resource.count
      end
    end

    describe 'with :count param' do
      let(:count) { 2 }
      let(:query) { { count: count } }

      it 'limits results to count' do
        expect(subject.scim_paginate(resource).count).to eq count
      end
    end

    describe 'with :startIndex param' do
      it 'starts from an offset' do
        query = { startIndex: Identity.count }

        result = pagination_class.new(query).scim_paginate(resource)

        expect(result.count).to eq(1)
        expect(result).to eq [resource.last]
      end

      it 'uses a 1-based index' do
        query = { startIndex: '1' }

        result = pagination_class.new(query).scim_paginate(resource)

        expect(result.count).to eq(Identity.count)
      end

      it 'uses 1 when provided an index less than 1' do
        query = { startIndex: 0 }

        result = pagination_class.new(query).scim_paginate(resource)

        expect(result.count).to eq(Identity.count)
      end
    end
  end
end

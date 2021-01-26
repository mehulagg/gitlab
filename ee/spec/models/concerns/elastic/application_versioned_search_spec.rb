# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::ApplicationVersionedSearch do
  let(:klass) do
    Class.new(ApplicationRecord) do
      include Elastic::ApplicationVersionedSearch

      has_many :widgets
    end
  end

  describe '.elastic_index_dependant_association' do
    it 'adds the associations to elastic_index_dependants' do
      klass.elastic_index_dependant_association(:widgets, on_change: :title)

      expect(klass.elastic_index_dependants).to include({
        association_name: :widgets,
        on_change: :title
      })
    end

    context 'when the association does not exist' do
      it 'raises an error' do
        expect { klass.elastic_index_dependant_association(:foo_bars, on_change: :bar) }
          .to raise_error("Invalid association to index. \"foo_bars\" is either not a collection or not an association. Hint: You must declare the has_many before declaring elastic_index_dependant_association.")
      end
    end

    context 'when the class is not an ApplicationRecord' do
      let(:not_application_record) do
        Class.new do
          include Elastic::ApplicationVersionedSearch
        end
      end

      it 'raises an error' do
        expect { not_application_record.elastic_index_dependant_association(:widgets, on_change: :title) }
          .to raise_error("elastic_index_dependant_association is not applicable as this class is not an ActiveRecord model.")
      end
    end
  end
end

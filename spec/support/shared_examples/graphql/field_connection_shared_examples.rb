# frozen_string_literal: true

RSpec.shared_examples 'field connections support pagination' do |type_object|
  it 'checks for keyset pagination support', :aggregate_failures do
    if type_object.respond_to?(:fields)
      type_object.fields.each_value do |field|
        if field.respond_to?(:connection?) && field.connection?
          expect(field.type.unwrap.metadata[:type_class].node_type.supports_keyset_pagination?)
            .to be_truthy,
                "Field `#{field.name}` of `#{type_object.name}` expected `#{field.type.unwrap.metadata[:type_class].node_type}` to support connections"
        end
      end
    end
  end
end

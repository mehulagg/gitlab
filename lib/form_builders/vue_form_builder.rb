# frozen_string_literal: true

module FormBuilders
  class FieldNameAndId < ActionView::Helpers::Tags::Base
    def render
      options = @options.stringify_keys
      add_default_name_and_id(options)

      options
    end
  end

  class VueFormBuilder < ActionView::Helpers::FormBuilder
    def field_name_and_id(method)
      FormBuilders::FieldNameAndId.new(@object_name, method, self).render
    end
  end
end

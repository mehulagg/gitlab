# frozen_string_literal: true

module EE
  module Banzai
    module Filter
      module LabelReferenceFilter
        extend ::Gitlab::Utils::Override

        override :data_attributes_for
        def data_attributes_for(text, parent, object, link_content: false, link_reference: false)
          return super unless object.scoped_label?

          # Enabling HTML tooltips for scoped labels here but we do not need to do any additional
          # escaping because the label's tooltips are already stripped of dangerous HTML
          super.merge!(
            html: true
          )
        end
      end
    end
  end
end

# frozen_string_literal: true

module EE
  module Banzai
    module Filter
      module References
        module LabelReferenceFilter
          extend ::Gitlab::Utils::Override

          override :data_attributes_for
          def data_attributes_for(text, parent, object, link_content: false, link_reference: false)
            return super unless object.scoped_label?

            # Enabling HTML tooltips for scoped labels here and additional escaping is done in `object_link_title`
            super.merge!(
              html: true
            )
          end

          override :object_link_title
          def object_link_title(object, matches)
            return super unless object.scoped_label?

            ERB::Util.html_escape(super)
          end
        end
      end
    end
  end
end

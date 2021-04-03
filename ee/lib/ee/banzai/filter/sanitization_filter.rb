# frozen_string_literal: true

module EE
  module Banzai
    module Filter
      module SanitizationFilter
        extend ::Gitlab::Utils::Override
        extend ActiveSupport::Concern

        override :customize_allowlist
        def customize_allowlist(allowlist)
          # Remove any `class` property not required for a
          allowlist[:attributes]['a'].push('class')
          allowlist[:transformers].push(self.class.remove_unsafe_a_class)

          super(allowlist)
        end

        class_methods do
          def remove_unsafe_a_class
            lambda do |env|
              node = env[:node]

              return unless node.name == 'a'
              return unless node.has_attribute?('class')

              return if node['class'] == ::Banzai::Filter::JiraPrivateImageLinkFilter::CSS_WITH_ATTACHMENT_ICON

              node.remove_attribute('class')
            end
          end
        end
      end
    end
  end
end

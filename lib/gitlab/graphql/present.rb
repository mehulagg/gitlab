# frozen_string_literal: true

module Gitlab
  module Graphql
    module Present
      extend ActiveSupport::Concern
      prepended do
        def self.present_using(kls)
          @presenter_class = kls
        end

        def self.presenter_class
          @presenter_class
        end

        def self.wrap(object, attrs)
          @presenter_class.new(object, **attrs)
        end
      end

      def present(object_type, attrs)
        klass = object_type.try(:presenter_class)
        return if !klass || object.is_a?(klass)

        self.unwrapped ||= object
        # The @object variable is not exposed through a setter
        @object = object_type.wrap(unwrapped, attrs) # rubocop: disable Gitlab/ModuleWithInstanceVariables
      end

      def unpresented
        unwrapped || object
      end

      private

      attr_accessor :unwrapped
    end
  end
end

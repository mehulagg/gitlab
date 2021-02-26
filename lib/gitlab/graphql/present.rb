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
      end

      def present(attrs)
        klass = self.class.presenter_class
        return if !klass || object.is_a?(klass)

        # The @object variable is not exposed through a setter
        @object = klass.new(object, **attrs) # rubocop: disable Gitlab/ModuleWithInstanceVariables
      end
    end
  end
end

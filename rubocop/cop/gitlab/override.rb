# frozen_string_literal: true

module RuboCop
  module Cop
    module Gitlab
      # This cop checks for `override :method_name` in methods where `super`
      # is used.
      #
      # See https://docs.gitlab.com/ee/development/utilities.html#override
      #
      # @example
      #
      # # bad
      # class Foo
      #   def foo
      #     super
      #   end
      # end
      #
      # class Foo
      #   override :bar
      #   def foo
      #     super
      #   end
      # end
      #
      # # good
      # class Foo
      #   extend ::Gitlab::Utils::Override
      #
      #   override :foo
      #   def foo
      #     super
      #   end
      # end
      #
      class Override < RuboCop::Cop::Cop
        MSG_MISSING_OVERRIDE = 'Use `override :%{name}` when overridding methods.'
        MSG_OVERRIDE_NAME_MISMATCH = 'Use `override :%{name}` instead of `override :%{wrong_name}`.'
        LINK = ' See https://docs.gitlab.com/ee/development/utilities.html#override'

        def_node_matcher :override, <<~PATTERN
          (begin
            (send nil? :override (sym $_))
            ...
          )
        PATTERN

        # Example: super
        def on_super(node)
          def_node = node.each_ancestor(:def).first
          return unless def_node

          match = override(def_node.parent)
          name = def_node.method_name

          return if match == name

          if match.nil?
            offense(def_node, MSG_MISSING_OVERRIDE, name)
          else
            offense(def_node, MSG_OVERRIDE_NAME_MISMATCH, name, wrong_name: match)
          end
        end

        # Example: super(with, args)
        alias_method :on_zsuper, :on_super

        private

        def offense(def_node, msg, name, **args)
          message = format(msg + LINK, name: name, **args)
          add_offense(def_node, message: message)
        end
      end
    end
  end
end

# frozen_string_literal: true

require_relative '../../code_reuse_helpers.rb'

module RuboCop
  module Cop
    module Scalability
      # This cop checks for usage of `type: :ops` feature flags
      #
      # Since we should not have many of such feature flags,
      # the rubocop rule should be disabled where they are used.
      # Unless, strictly necessary development feature flag
      # should be used.
      #
      # @example
      #
      # bad
      #
      # Feature.enabled?(:my_flag, type: :ops)
      # Feature.disabled?(:my_flag, type: :ops)
      # push_frontend_feature_flag(:my_flag, type: :ops)
      #
      # good
      #
      # Feature.enabled?(:my_flag)
      # Feature.disabled?(:my_flag)
      # push_frontend_feature_flag(:my_flag)
      #
      class OpsFeatureFlag < RuboCop::Cop::Cop
        HELP_LINK = 'https://docs.gitlab.com/ee/development/feature_flags/development.html#ops-type'

        MSG = <<~MSG
          The usage of `type: :ops` feature flags is restricted.

          The Ops feature flags are long-lived. Unless strictly necessary
          a development feature flag should be used.

          The Ops should be used only for checks that we don't really
          plan ever to remove. Rather, we treat these feature flags
          as "disaster recovery" if something goes wrong.

          Please read the #{HELP_LINK} or reach to ~"team::Scalability"
          for review whether your usage is appropiate.
        MSG

        def_node_matcher :feature_enabled_or_disabled?, <<~PATTERN
          (send
            (const _ :Feature) { :enabled? :disabled? }
            ...
            (hash <(pair (sym :type) (sym :ops)) ...>)
          )
        PATTERN

        def_node_matcher :push_frontend_feature_flag?, <<~PATTERN
          (send
            _ :push_frontend_feature_flag
            ...
            (hash <(pair (sym :type) (sym :ops)) ...>)
          )
        PATTERN

        def on_send(node)
          if feature_enabled_or_disabled?(node) || push_frontend_feature_flag?(node)
            add_offense(node)
          end
        end
      end
    end
  end
end

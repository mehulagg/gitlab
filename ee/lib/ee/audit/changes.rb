# frozen_string_literal: true

module EE
  module Audit
    module Changes
      # Records an audit event in DB for model changes
      #
      # @param [Symbol] column column name to be audited
      # @param [Hash] opts the options to create an event with
      # @option opts [Symbol] :column column name to be audited
      # @option opts [User, Project, Group] :target_model level the event belongs to
      # @option opts [Object] :model object being audited
      # @option opts [Boolean] :skip_changes whether to record from/to values
      #
      # @return [SecurityEvent, nil] the resulting object or nil if there is no
      #   change detected
      def audit_changes(column, options = {})
        column = options[:column] || column
        # rubocop:disable Gitlab/ModuleWithInstanceVariables
        @target_model = options[:target_model]
        @model = options[:model]
        # rubocop:enable Gitlab/ModuleWithInstanceVariables

        return unless changed?(column)

        audit_event(parse_options(column, options))
      end

      protected

      def target_model
        @target_model || model # rubocop:disable Gitlab/ModuleWithInstanceVariables
      end

      def model
        @model
      end

      private

      def changed?(column)
        model.previous_changes.has_key?(column) && !model.previous_changes.has_key?(:id)
      end

      def changes(column)
        model.previous_changes[column]
      end

      def parse_options(column, options)
        options.tap do |options_hash|
          options_hash[:column] = column
          options_hash[:action] = :update

          unless options[:skip_changes]
            options_hash[:from] = changes(column).first
            options_hash[:to] = changes(column).last
          end
        end
      end

      def audit_event(options)
        ::AuditEventService.new(@current_user, target_model, options) # rubocop:disable Gitlab/ModuleWithInstanceVariables
          .for_changes(model).security_event
      end
    end
  end
end

# frozen_string_literal: true

module Gitlab
  module Geo
    module ReplicableModel
      extend ActiveSupport::Concern
      include Checksummable

      included do
        # If this hook turns out not to apply to all Models, perhaps we should extract a `ReplicableBlobModel`
        after_create_commit -> { replicator.handle_after_create_commit if replicator.respond_to?(:handle_after_create_commit) }
        after_destroy -> { replicator.handle_after_destroy if replicator.respond_to?(:handle_after_destroy) }

        # Temporarily defining `verification_succeeded` and
        # `verification_failed` for unverified models while verification is
        # under development to avoid breaking GeoNodeStatusCheck code.
        # TODO: Remove these after including `Gitlab::Geo::VerificationState` on
        # all models. https://gitlab.com/gitlab-org/gitlab/-/issues/280768
        scope :verification_succeeded, -> { none }
        scope :verification_failed, -> { none }
        scope :available_replicables, -> { all }
      end

      class_methods do
        # Associate current model with specified replicator
        #
        # @param [Gitlab::Geo::Replicator] klass
        def with_replicator(klass)
          raise ArgumentError, 'Must be a class inheriting from Gitlab::Geo::Replicator' unless klass < ::Gitlab::Geo::Replicator

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            define_method :replicator do
              @_replicator ||= klass.new(model_record: self)
            end

            define_singleton_method :replicator_class do
              @_replicator_class ||= klass
            end
          RUBY
        end
      end

      # Geo Replicator
      #
      # @abstract
      # @return [Gitlab::Geo::Replicator]
      def replicator
        raise NotImplementedError, 'There is no Replicator defined for this model'
      end

      # Returns a checksum of the file (assumed to be a "blob" type)
      #
      # @return [String] SHA256 hash of the carrierwave file
      def calculate_checksum
        return unless checksummable?

        self.class.hexdigest(replicator.carrierwave_uploader.path)
      end

      # Checks whether model needs checksum to be performed
      #
      # Conditions:
      # - No checksum is present
      # - It's capable of generating a checksum of itself
      #
      # @return [Boolean]
      def needs_checksum?
        verification_checksum.nil? && checksummable?
      end

      # Return whether its capable of generating a checksum of itself
      #
      # @return [Boolean] whether it can generate a checksum
      def checksummable?
        local? && file_exist?
      end

      # This checks for existence of the file on storage
      #
      # @return [Boolean] whether the file exists on storage
      def file_exist?
        if local?
          File.exist?(replicator.carrierwave_uploader.path)
        else
          replicator.carrierwave_uploader.exists?
        end
      end

      def in_replicables_for_current_secondary?
        self.class.replicables_for_current_secondary(self).exists?
      end
    end
  end
end

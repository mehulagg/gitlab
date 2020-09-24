# frozen_string_literal: true

module EE
  module LicenseHelpers
    extend ActiveSupport::Concern

    # Enable/Disable a feature on the License for a spec.
    #
    # Example:
    #
    #   stub_licensed_features(geo: true, deploy_board: false)
    #
    # This enables `geo` and disables `deploy_board` features for a spec.
    # Other features are still enabled/disabled as defined in the license.

    prepended do
      def stub_licensed_features(features)
        # EEU_FEATURES contains all the features we know about
        missing_features = features.keys.map(&:to_sym) - License::EEU_FEATURES

        if missing_features.any?
          subject = missing_features.join(', ')
          noun = 'feature'.pluralize(missing_features.size)
          raise ArgumentError, "#{subject} should be defined as licensed #{noun}"
        end

        allow(License).to receive(:feature_available?).and_call_original

        features.each do |feature, enabled|
          allow(License).to receive(:feature_available?).with(feature) { enabled }
        end
      end

      def enable_namespace_license_check!
        stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
        ::Gitlab::CurrentSettings.update!(check_namespace_plan: true)
      end

      def create_current_license(options = {})
        License.current.destroy!

        gl_license = create(:gitlab_license, options)
        create(:license, data: gl_license.export)
      end
    end
  end
end

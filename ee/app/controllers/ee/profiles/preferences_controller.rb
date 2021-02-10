# frozen_string_literal: true

module EE::Profiles::PreferencesController
  extend ::Gitlab::Utils::Override

  override :preferences_param_names
  def preferences_param_names
    super + preferences_param_names_ee
  end

  def preferences_param_names_ee
    License.feature_available?(:security_dashboard) ? %i[group_view] : []
  end
end

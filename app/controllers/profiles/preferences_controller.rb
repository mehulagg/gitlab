# frozen_string_literal: true

class Profiles::PreferencesController < Profiles::ApplicationController
  before_action :user

  def show
  end

  def update
    respond_to do |format|
      result = Users::UpdateService.new(current_user, preferences_params.merge(user: user)).execute

      if result[:status] == :success
        message = s_('Preferences saved.')

        format.html { redirect_back_or_default(default: { action: 'show' }, options: { notice: message }) }
        format.json { render json: { message: message } }
      else
        format.html { redirect_back_or_default(default: { action: 'show' }, options: { alert: result[:message] }) }
        format.json { render json: result }
      end
    end
  end

  private

  def user
    @user = current_user
  end

  def preferences_params
    params.require(:user).permit(preferences_param_names)
  end

  def preferences_param_names
    [
      :color_scheme_id,
      :layout,
      :dashboard,
      :project_view,
      :theme_id,
      :first_day_of_week,
      :preferred_language,
      :time_display_relative,
      :time_format_in_24h,
      :show_whitespace_in_diffs,
      :view_diffs_file_by_file,
      :tab_width,
      :sourcegraph_enabled,
      :gitpod_enabled,
      :render_whitespace_in_code
    ]
  end
end

Profiles::PreferencesController.prepend_if_ee('::EE::Profiles::PreferencesController')

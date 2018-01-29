class Projects::VariablesController < Projects::ApplicationController
  prepend ::EE::Projects::VariablesController

  before_action :authorize_admin_build!

  def show
    respond_to do |format|
      format.json do
        variables = @project.variables
          .map { |variable| variable.present(current_user: current_user) }

        render status: :ok, json: { variables: variables }
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        return head :ok if @project.update(variables_params)

        render status: :bad_request, json: @project.errors.full_messages
      end
    end
  end

  private

  def variables_params
    params.permit(variables_attributes: [*variable_params_attributes])
  end

  def variable_params_attributes
    %i[id key value protected _destroy]
  end
end

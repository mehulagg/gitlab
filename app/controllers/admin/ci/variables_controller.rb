# frozen_string_literal: true

class Admin::Ci::VariablesController < Admin::ApplicationController
  include ::Audit::Changes

  feature_category :pipeline_authoring

  def show
    respond_to do |format|
      format.json { render_instance_variables }
    end
  end

  def update
    service = Ci::UpdateInstanceVariablesService.new(variables_params)
    $stderr.puts "--- Sam debug ---"
    $stderr.puts variable_params:
    log_audit_event(variables_params)

    if service.execute
      respond_to do |format|
        format.json { render_instance_variables }
      end
    else
      respond_to do |format|
        format.json { render_error(service.errors) }
      end
    end
  end

  private

  def variables
    @variables ||= Ci::InstanceVariable.all
  end

  def render_instance_variables
    render status: :ok,
      json: {
        variables: Ci::InstanceVariableSerializer.new.represent(variables)
      }
  end

  def render_error(errors)
    render status: :bad_request, json: errors
  end

  def variables_params
    params.permit(variables_attributes: [*variable_params_attributes])
  end

  def variable_params_attributes
    %i[id variable_type key secret_value protected masked _destroy]
  end

  def log_audit_event(target)
    audit_context = {
      #name: 'instance_ci_variable_created',
      author: current_user,
      scope: Hash["id"=>123, "class" => Hash["name" =>"sam"]],
      target: target,
      message: "Changed instance CI variable"
    }

    Gitlab::Audit::Auditor.audit(audit_context)
  end
end

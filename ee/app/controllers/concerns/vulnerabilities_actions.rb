# frozen_string_literal: true

# The VulnerabilitiesActions concern contains actions that are used to populate vulnerabilities
# on security dashboards.
#
# Note: Consumers of this module will need to define a `def vulnerable` method, which must return
# an object with an interface that matches the one provided by the Vulnerable model concern.

module VulnerabilitiesActions
  extend ActiveSupport::Concern

  def index
    vulnerabilities = found_vulnerabilities(:with_sha).ordered.page(params[:page])

    # Move hide_vulnerabilities filter to Vulnerabilities::Finder when db query can be used
    # To be removed with: https://gitlab.com/gitlab-org/gitlab-ee/issues/14042

    hide_dismissed = filter_params[:hide_dismissed].present? && filter_params[:hide_dismissed] == true


    respond_to do |format|
      format.json do
        render json: Vulnerabilities::OccurrenceSerializer
          .new(current_user: current_user)
          .with_pagination(request, response)
          .represent(vulnerabilities, hide_dismissed: hide_dismissed)
      end
    end
  end

  def summary
    if filter_params[:hide_dismissed].present? && filter_params[:hide_dismissed] == true
      vulnerabilities = found_vulnerabilities.reject(&:dismissed?)
      vulnerabilities_summary = vulnerabilities.group_by { |o| o[:severity] }.map { |key, o| [Vulnerabilities::Occurrence::SEVERITY_LEVELS[key], o.count] }.to_h
    else
      vulnerabilities_summary = found_vulnerabilities.counted_by_severity
    end

    respond_to do |format|
      format.json do
        render json: VulnerabilitySummarySerializer.new.represent(vulnerabilities_summary)
      end
    end
  end

  private

  def filter_params
    params.permit(report_type: [], confidence: [], project_id: [], severity: [])
      .merge(hide_dismissed: ::Gitlab::Utils.to_boolean(params[:hide_dismissed]))
  end

  def found_vulnerabilities(collection = :latest)
    ::Security::VulnerabilitiesFinder.new(vulnerable, params: filter_params).execute(collection)
  end
end

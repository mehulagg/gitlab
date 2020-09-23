# frozen_string_literal: true

module DescriptionDiffActions
  extend ActiveSupport::Concern
  include Gitlab::Utils::StrongMemoize

  included do
    before_action :verify_description_diffs_enabled!, only: [:description_diff, :delete_description_version]
    before_action :authorize_delete_description_version!, only: :delete_description_version
  end

  def description_diff
    return render_404 if previous_description_version.nil?

    diff = Gitlab::Diff::CharDiff.new(previous_description_version.description, description_version.description)
    diff.generate_diff

    render html: diff.to_html
  end

  def delete_description_version
    description_version.delete!(start_id: params[:start_version_id])

    head :ok
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  private

  def previous_description_version
    strong_memoize(:previous_description_version) do
      if params[:start_version_id].present?
        issuable.description_versions.visible.find(params[:start_version_id]).previous_version
      else
        description_version.previous_version
      end
    end
  end

  def description_version
    strong_memoize(:description_version) do
      issuable.description_versions.visible.find(params[:version_id])
    end
  end

  def verify_description_diffs_enabled!
    return render_404 unless issuable.resource_parent.feature_available?(:description_diffs)
  end

  def authorize_delete_description_version!
    rule = "admin_#{issuable.class.to_ability_name}"

    return render_404 unless can?(current_user, rule, issuable)
  end
end

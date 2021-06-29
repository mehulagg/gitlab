# frozen_string_literal: true

class MoveCiTables < ActiveRecord::Migration[6.1]
  include Gitlab::Database::SchemaHelpers

  DOWNTIME = false

  # Script to generate that list: add `tags` and `taggings` additionally
  # Dir.glob('app/models/ci/**/*.rb').each { |f| require_relative(f) rescue nil }
  # Dir.glob('ee/app/models/ci/**/*.rb').each { |f| require_relative(f) rescue nil }
  # Ci::ApplicationRecord.descendants.map(&:table_name).uniq.sort

  TABLES = [
    "tags",
    "taggings",
    "ci_build_needs",
    "ci_build_pending_states",
    "ci_build_report_results",
    "ci_build_trace_chunks",
    "ci_build_trace_section_names",
    "ci_build_trace_sections",
    "ci_builds",
    "ci_builds_metadata",
    "ci_builds_runner_session",
    "ci_daily_build_group_report_results",
    "ci_deleted_objects",
    "ci_freeze_periods",
    "ci_group_variables",
    "ci_instance_variables",
    "ci_job_artifacts",
    "ci_job_token_project_scope_links",
    "ci_job_variables",
    "ci_minutes_additional_packs",
    "ci_namespace_monthly_usages",
    "ci_pending_builds",
    "ci_pipeline_artifacts",
    "ci_pipeline_chat_data",
    "ci_pipeline_messages",
    "ci_pipeline_schedule_variables",
    "ci_pipeline_schedules",
    "ci_pipeline_variables",
    "ci_pipelines",
    "ci_pipelines_config",
    "ci_project_monthly_usages",
    "ci_refs",
    "ci_resource_groups",
    "ci_resources",
    "ci_runner_namespaces",
    "ci_runner_projects",
    "ci_runners",
    "ci_running_builds",
    "ci_sources_pipelines",
    "ci_sources_projects",
    "ci_stages",
    "ci_subscriptions_projects",
    "ci_trigger_requests",
    "ci_triggers",
    "ci_unit_test_failures",
    "ci_unit_tests",
    "ci_variables"
  ]

  def up
    TABLES.each do |table|
      execute "ALTER TABLE #{table} SET SCHEMA gitlab_ci"
    end
  end

  def down
    TABLES.each do |table|
      execute "ALTER TABLE #{table} SET SCHEMA public"
    end
  end
end

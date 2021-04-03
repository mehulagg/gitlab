# frozen_string_literal: true

class ApplyMaxAnalyzedOffset < Elastic::Migration
  # Important: Any update to the Elastic index mappings should be replicated in Elastic::Latest::Config

  def migrate
    if max_analyzed_offset_setting == current_max_analyzed_offset
      log "Skipping highlight.max_analyzed_offset migration since it is already applied"
      return
    end

    log "Setting highlight.max_analyzed_offset to #{max_analyzed_offset_setting}kb"
    helper.update_settings(settings: { index: { 'highlight.max_analyzed_offset': max_analyzed_offset_setting } })
    log 'Update of highlight.max_analyzed_offset is completed'
  end

  # Check if the migration has completed
  # Return true if completed, otherwise return false
  def completed?
    max_analyzed_offset_setting == current_max_analyzed_offset
  end

  private

  def max_analyzed_offset_setting
    Gitlab::CurrentSettings.elasticsearch_indexed_file_size_limit_kb.kilobytes
  end

  def current_max_analyzed_offset
    Gitlab::Elastic::Helper.default.get_settings.dig('highlight', 'max_analyzed_offset').to_i
  end
end

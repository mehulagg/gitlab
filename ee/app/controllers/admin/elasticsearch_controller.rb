# frozen_string_literal: true

class Admin::ElasticsearchController < Admin::ApplicationController
  feature_category :global_search

  # POST
  # Scheduling indexing jobs
  def enqueue_index
    if Gitlab::Elastic::Helper.default.index_exists?
      ::Elastic::IndexProjectsService.new.execute

      notice = _('Elasticsearch indexing started')
      queue_link = helpers.link_to(_('(check progress)'), sidekiq_path + '/queues/elastic_commit_indexer')
      flash[:notice] = "#{notice} #{queue_link}".html_safe
    else
      flash[:warning] = _('Please create an index before enabling indexing')
    end

    redirect_to redirect_path
  end

  # POST
  # Trigger reindexing task
  def trigger_reindexing
    if Elastic::ReindexingTask.running?
      flash[:warning] = _('Elasticsearch reindexing is already in progress')
    else
      Elastic::ReindexingTask.create!(max_slices_running: trigger_reindexing_params[:max_slices_running].to_i,
                                      slice_multiplier: trigger_reindexing_params[:slice_multiplier].to_i)
      flash[:notice] = _('Elasticsearch reindexing triggered')
    end

    redirect_to redirect_path(anchor: 'js-elasticsearch-reindexing')
  end

  # POST
  # Cancel index deletion after a successful reindexing operation
  def cancel_index_deletion
    task = Elastic::ReindexingTask.find(params[:task_id])
    task.update!(delete_original_index_at: nil)

    flash[:notice] = _('Index deletion is canceled')

    redirect_to redirect_path(anchor: 'js-elasticsearch-reindexing')
  end

  # POST
  # Retry a halted migration
  def retry_migration
    migration = Elastic::DataMigrationService[params[:version].to_i]

    Gitlab::Elastic::Helper.default.delete_migration_record(migration)
    Elastic::DataMigrationService.drop_migration_halted_cache!(migration)

    flash[:notice] = _('Migration has been scheduled to be retried')

    redirect_to redirect_path
  end

  private

  def redirect_path(anchor: 'js-elasticsearch-settings')
    advanced_search_admin_application_settings_path(anchor: anchor)
  end

  def trigger_reindexing_params
    params.permit(elasticsearch_reindexing_task: %i(max_slices_running slice_multiplier))
  end
end

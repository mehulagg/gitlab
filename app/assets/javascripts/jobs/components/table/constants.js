import { s__, __ } from '~/locale';

export const i18n = {
  downloadArtifacts: __('Download artifacts'),
  cancel: __('Cancel'),
  confirmationMessage: s__(
    `DelayedJobs|Are you sure you want to run %{job_name} immediately? This job will run automatically after it's timer finishes.`,
  ),
  startNow: s__('DelayedJobs|Start now'),
  unschedule: s__('DelayedJobs|Unschedule'),
  play: __('Play'),
  retry: __('Retry'),
};

import ExperimentTracking from '~/experiment_tracking';

function trackEvent(eventName) {
  const property = !!document.querySelector('.project-home-panel.empty-project') ? 'empty' : 'nonempty';
  const label = 'blob-upload-modal';
  const Tracking = new ExperimentTracking('empty_repo_upload', { label, property });

  Tracking.event(eventName);
}

export function initUploadFileTrigger() {
  const uploadFileTriggerEl = document.querySelector('.js-upload-file-experiment-trigger');

  if (uploadFileTriggerEl) {
    uploadFileTriggerEl.addEventListener('click', () => {
      trackEvent('click_upload_modal_trigger');
    });
  }
}

export function trackUploadFileFormSubmitted() {
  trackEvent('click_upload_modal_form_submit');
}

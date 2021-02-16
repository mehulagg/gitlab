import $ from 'jquery';
import 'bootstrap/js/dist/modal';
import initTrialStatusWidget from 'ee/contextual_sidebar/group_trial_status_widget';
import initEETrialBanner from 'ee/ee_trial_banner';
import trackNavbarEvents from 'ee/event_tracking/navbar';
import initNamespaceStorageLimitAlert from 'ee/namespace_storage_limit_alert';

$(() => {
  /**
   * EE specific scripts
   */
  $('#modal-upload-trial-license').modal('show');

  // EE specific calls
  initEETrialBanner();
  initNamespaceStorageLimitAlert();

  trackNavbarEvents();

  initTrialStatusWidget();
});

import $ from 'jquery';
import 'bootstrap/js/dist/modal';
import initEETrialBanner from 'ee/ee_trial_banner';
import trackNavbarEvents from 'ee/event_tracking/navbar';
import initNamespaceStorageLimitAlert from 'ee/namespace_storage_limit_alert';
import initCCVerificationRequiredCallout from 'ee/credit_card_verification_required_callout';

$(() => {
  /**
   * EE specific scripts
   */
  $('#modal-upload-trial-license').modal('show');

  // EE specific calls
  initEETrialBanner();
  initNamespaceStorageLimitAlert();
  initCCVerificationRequiredCallout();

  trackNavbarEvents();
});

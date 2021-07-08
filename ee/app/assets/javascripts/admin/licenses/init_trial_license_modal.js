import Vue from 'vue';
import UploadTrialLicenseModal from './components/upload_trial_license_modal.vue';

export default function initUploadTrialLicenseModal() {
  const el = document.querySelector('.js-upload-trial-license-modal');

  if (!el) {
    return false;
  }
  const { licenseKey, adminLicensePath } = el.dataset;

  return new Vue({
    el,
    render(h) {
      return h(UploadTrialLicenseModal, {
        props: {
          licenseKey,
          adminLicensePath,
        },
      });
    },
  });
}

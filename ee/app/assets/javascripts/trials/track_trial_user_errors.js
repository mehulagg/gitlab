import Tracking from '~/tracking';

export default function trackTrialUserErrors() {
  const flashText = document.querySelector('.trial-errors .flash-text');

  if (flashText) {
    const errorMessage = flashText.textContent.trim();

    if (errorMessage) {
      Tracking.event('trials:create', 'create_trial_error', {
        label: 'flash-text',
        property: 'message',
        value: errorMessage,
      });
    }
  }
}
document.addEventListener('SnowplowInitialized', trackTrialUserErrors);

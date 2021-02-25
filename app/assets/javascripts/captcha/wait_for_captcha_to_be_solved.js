import Vue from 'vue';
import { __ } from '~/locale';

/**
 * Opens a Captcha Modal with provided captchaSiteKey.
 *
 * Returns a Promise which resolves if the captcha is solved correctly, and rejects
 * if the captcha process is aborted.
 *
 * @param captchaSiteKey
 * @returns {Promise}
 */
export default function waitForCaptchaToBeSolved(captchaSiteKey) {
  return new Promise((resolve, reject) => {
    const captchaModalElement = document.createElement('div');

    let captchaModalVueInstance;

    const receivedCaptchaResponse = (captchaResponse) => {
      // Cleaning up the modal from the DOM
      captchaModalVueInstance.$destroy();
      captchaModalElement.remove();

      if (captchaResponse) {
        // If the user solved the captcha resubmit the form, pass along the
        // captchaResponse and spamLogId as spamParams, and reset them to
        // blank in the local component data.
        resolve(captchaResponse);
      } else {
        // If the user didn't solve the captcha (e.g. they just closed the modal),
        // finish the update and allow them to continue editing or manually resubmit the form.
        reject(new Error(__('You must solve the CAPTCHA in order to submit')));
      }
    };

    document.body.append(captchaModalElement);

    captchaModalVueInstance = new Vue({
      el: captchaModalElement,
      components: {
        CaptchaModal: () => import('~/captcha/captcha_modal.vue'),
      },
      render: (createElement) => {
        return createElement('captcha-modal', {
          props: {
            captchaSiteKey,
            needsCaptchaResponse: true,
          },
          on: {
            receivedCaptchaResponse,
          },
        });
      },
    });
  });
}

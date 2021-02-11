import Vue from 'vue';
import { __ } from '~/locale';
import axios from '../lib/utils/axios_utils';

function showCaptchaModal(captchaSiteKey) {
  return new Promise((resolve, reject) => {
    const captchaModalElement = document.createElement('div');
    document.body.append(captchaModalElement);

    // eslint-disable-next-line no-unused-vars
    const captchaModalVueInstance = new Vue({
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
            receivedCaptchaResponse: (captchaResponse) => {
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
            },
          },
        });
      },
    });
  });
}

export default function registerCaptchaModalInterceptor() {
  return axios.interceptors.response.use(
    (response) => {
      return response;
    },
    (err) => {
      const { data } = err.response;
      if (data.needs_captcha_response) {
        const captchaSiteKey = data.captcha_site_key;
        const spamLogId = data.spam_log_id;
        return showCaptchaModal(captchaSiteKey).then((captchaResponse) => {
          const errConfig = err.config;
          const originalData = JSON.parse(errConfig.data);
          return axios({
            method: errConfig.method,
            url: err.config.url,
            data: {
              ...originalData,
              captcha_response: captchaResponse,
              spam_log_id: spamLogId,
            },
          });
        });
      }

      return Promise.reject(err);
    },
  );
}

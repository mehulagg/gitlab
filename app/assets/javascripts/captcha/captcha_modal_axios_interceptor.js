import axios from '../lib/utils/axios_utils';
import waitForCaptchaToBeSolved from './wait_for_captcha_to_be_solved';

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
        return waitForCaptchaToBeSolved(captchaSiteKey).then((captchaResponse) => {
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

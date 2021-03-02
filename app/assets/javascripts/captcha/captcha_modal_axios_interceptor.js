import waitForCaptchaToBeSolved from '~/captcha/wait_for_captcha_to_be_solved';

const supportedMethods = ['patch', 'post', 'put'];

export default function registerCaptchaModalInterceptor(axios) {
  return axios.interceptors.response.use(
    (response) => {
      return response;
    },
    (err) => {
      if (
        supportedMethods.includes(err?.config?.method) &&
        err?.response?.data?.needs_captcha_response
      ) {
        const { data } = err.response;
        const captchaSiteKey = data.captcha_site_key;
        const spamLogId = data.spam_log_id;
        return waitForCaptchaToBeSolved(captchaSiteKey).then((captchaResponse) => {
          const errConfig = err.config;
          const originalData = JSON.parse(errConfig.data);
          return axios({
            method: errConfig.method,
            url: errConfig.url,
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

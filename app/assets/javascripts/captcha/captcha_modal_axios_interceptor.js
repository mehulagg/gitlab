const supportedMethods = ['patch', 'post', 'put'];

export function registerCaptchaModalInterceptor(axios) {
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
        return (
          // eslint-disable-next-line promise/no-promise-in-callback
          import('~/captcha/wait_for_captcha_to_be_solved')
            // show the CAPTCHA modal and wait for it to be solved or closed
            .then(({ waitForCaptchaToBeSolved }) => waitForCaptchaToBeSolved(captchaSiteKey))
            // resubmit the original request with the captcha_response and spam_log_id in the headers
            .then((captchaResponse) => {
              const errConfig = err.config;
              const originalData = JSON.parse(errConfig.data);
              return axios({
                method: errConfig.method,
                url: errConfig.url,
                headers: {
                  'X-GitLab-Captcha-Response': captchaResponse,
                  'X-GitLab-Spam-Log-Id': spamLogId,
                },
                data: {
                  ...originalData,
                },
              });
            })
        );
      }

      return Promise.reject(err);
    },
  );
}

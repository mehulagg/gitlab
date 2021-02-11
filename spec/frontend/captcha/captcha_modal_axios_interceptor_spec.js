import registerCaptchaModalInterceptor from '~/captcha/captcha_modal_axios_interceptor';
import axios from '~/lib/utils/axios_utils';

describe('registerCaptchaModalInterceptor', () => {
  let interceptorIndex;

  beforeEach(() => {
    interceptorIndex = registerCaptchaModalInterceptor();
  });

  describe('when request is fulfilled', () => {
    const TEST_RESPONSE = 'fulfilled';

    it('returns the response', () => {
      const result = axios.interceptors.response.handlers[interceptorIndex].fulfilled(
        TEST_RESPONSE,
      );
      expect(result).toBe(TEST_RESPONSE);
    });
  });

  describe('when request is rejected', () => {
    describe('when needs_captcha_response is false', () => {
      const error = {
        response: {
          data: {
            needs_captcha_response: false,
          },
        },
      };

      it('returns a promise rejected with the error', async () => {
        const result = axios.interceptors.response.handlers[interceptorIndex].rejected(error);
        let response;
        await result.catch((err) => {
          response = err;
        });
        expect(response).toBe(error);
      });
    });

    describe('when needs_captcha_response is true', () => {
      const TEST_CAPTCHA_SITE_KEY = 'abc123';
      const error = {
        response: {
          data: {
            needs_captcha_response: true,
            captcha_site_key: TEST_CAPTCHA_SITE_KEY,
          },
        },
      };

      // *******************************************************
      // *******************************************************
      // NOTE: SEE /Users/cwoolley/workspace/gitlab-development-kit/gitlab/spec/frontend/snippets/components/edit_spec.js
      //       line 371 for an example of testing the captcha modal
      // *******************************************************
      // *******************************************************
      it('obtains a CAPTCHA response via the modal then resubmits request', async () => {
        const result = axios.interceptors.response.handlers[interceptorIndex].rejected(error);
        let resp;
        await result.then((response) => {
          resp = response;
        });

        expect(resp).toBe('something???');
      });
    });
  });
});

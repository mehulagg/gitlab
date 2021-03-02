import MockAdapter from 'axios-mock-adapter';

import registerCaptchaModalInterceptor from '~/captcha/captcha_modal_axios_interceptor';
import waitForCaptchaToBeSolved from '~/captcha/wait_for_captcha_to_be_solved';
import axios from '~/lib/utils/axios_utils';

jest.mock('~/captcha/wait_for_captcha_to_be_solved');

describe('registerCaptchaModalInterceptor', () => {
  const SPAM_LOG_ID = 'SPAM_LOG_ID';
  const CAPTCHA_SITE_KEY = 'CAPTCHA_SITE_KEY';
  const CAPTCHA_SUCCESS = 'CAPTCHA_SUCCESS';
  const CAPTCHA_RESPONSE = 'CAPTCHA_RESPONSE';
  const AXIOS_RESPONSE = { text: 'AXIOS_RESPONSE' };
  const NEEDS_CAPTCHA_RESPONSE = {
    needs_captcha_response: true,
    captcha_site_key: CAPTCHA_SITE_KEY,
    spam_log_id: SPAM_LOG_ID,
  };

  const unsupportedMethods = ['get', 'head', 'options'];
  const supportedMethods = ['patch', 'post', 'put'];

  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    mock.onAny('/no-captcha').reply(200, AXIOS_RESPONSE);
    mock.onAny('/error').reply(404, AXIOS_RESPONSE);
    mock.onAny('/captcha').reply((config) => {
      if (!supportedMethods.includes(config.method)) {
        return [405, { method: config.method }];
      }

      try {
        const { captcha_response, spam_log_id, ...rest } = JSON.parse(config.data);
        // eslint-disable-next-line babel/camelcase
        if (captcha_response === CAPTCHA_RESPONSE && spam_log_id === SPAM_LOG_ID) {
          return [200, { ...rest, method: config.method, CAPTCHA_SUCCESS }];
        }
      } catch (e) {
        return [400, { method: config.method }];
      }

      return [409, NEEDS_CAPTCHA_RESPONSE];
    });
  });

  afterEach(() => {
    axios.interceptors.request.handlers = [];
    mock.restore();
  });

  describe.each([...supportedMethods, ...unsupportedMethods])('For HTTP method %s', (method) => {
    it('successful requests are passed through', async () => {
      registerCaptchaModalInterceptor(axios);

      const { data, status } = await axios[method]('/no-captcha');

      expect(status).toEqual(200);
      expect(data).toEqual(AXIOS_RESPONSE);
    });

    it('error requests without needs_captcha_response_errors are passed through', async () => {
      registerCaptchaModalInterceptor(axios);

      await expect(() => axios[method]('/error')).rejects.toThrow(
        expect.objectContaining({
          response: expect.objectContaining({ status: 404, data: AXIOS_RESPONSE }),
        }),
      );
    });
  });

  describe.each(supportedMethods)('For HTTP method %s', (method) => {
    describe('error requests with needs_captcha_response_errors', () => {
      const submittedData = { ID: 12345 };

      it('re-submits request if captcha was solved correctly', async () => {
        waitForCaptchaToBeSolved.mockImplementation(() => Promise.resolve(CAPTCHA_RESPONSE));
        registerCaptchaModalInterceptor(axios);

        const { data: returnedData } = await axios[method]('/captcha', submittedData);

        expect(waitForCaptchaToBeSolved).toHaveBeenCalledWith(CAPTCHA_SITE_KEY);

        expect(returnedData).toEqual({ ...submittedData, CAPTCHA_SUCCESS, method });
      });

      it('does not re-submit request if captcha was not solved', async () => {
        const error = new Error('Captcha not solved');
        waitForCaptchaToBeSolved.mockImplementation(() => Promise.reject(error));
        registerCaptchaModalInterceptor(axios);

        await expect(() => axios[method]('/captcha', submittedData)).rejects.toThrow(error);

        expect(waitForCaptchaToBeSolved).toHaveBeenCalledWith(CAPTCHA_SITE_KEY);
      });
    });
  });

  describe.each(unsupportedMethods)('For HTTP method %s', (method) => {
    it('ignores captcha response', async () => {
      registerCaptchaModalInterceptor(axios);

      await expect(() => axios[method]('/captcha')).rejects.toThrow(
        expect.objectContaining({
          response: expect.objectContaining({ status: 405, data: { method } }),
        }),
      );

      expect(waitForCaptchaToBeSolved).not.toHaveBeenCalled();
    });
  });
});

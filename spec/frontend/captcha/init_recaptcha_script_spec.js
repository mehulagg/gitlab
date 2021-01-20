import { initRecaptchaScript, clearMemoizeCache } from '~/captcha/init_recaptcha_script';

describe('initRecaptchaScript', () => {
  afterEach(() => {
    clearMemoizeCache();
  });

  it('appends the the reCAPTCHA script tag to the head of document', () => {
    // Clear the memoize cache in case it has previously been memoized
    clearMemoizeCache();

    const headSpy = jest.spyOn(document.head, 'appendChild');

    initRecaptchaScript();

    window.recaptchaOnloadCallback();

    expect(headSpy).toHaveBeenCalled();
  });
})

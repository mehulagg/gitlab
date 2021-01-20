import { memoize } from 'lodash';

/**
 * Adds the Google reCAPTCHA script tag to the head of the document, and
 * returns a promise which receives the name of the script's 'onload' callback
 * as a parameter.
 *
 * It is memoized, so there will only be one instance of the script tag ever
 * added to the document.
 *
 * See the reCAPTCHA documentation for more details:
 *
 * https://developers.google.com/recaptcha/docs/display#explicit_render
 *
 */
export const initRecaptchaScript = memoize(() => {
  /**
   * The name which will be used for the reCAPTCHA script's onload callback
   */
  const grecaptchaOnloadCallbackName = 'recaptchaOnloadCallback';

  /**
   * Appends the the reCAPTCHA script tag to the head of document
   */
  const appendRecaptchaScript = () => {
    // debugger
    const scriptSrc = `https://www.google.com/recaptcha/api.js?onload=${grecaptchaOnloadCallbackName}&render=explicit`;
    const script = document.createElement('script');
    script.src = scriptSrc;
    script.classList.add('js-recaptcha-script');
    script.async = true;
    script.defer = true;
    document.head.appendChild(script);
  };

  /**
   * Returns a Promise which is fulfilled after the reCAPTCHA script is loaded
   */
  return new Promise((resolve) => {
    window[grecaptchaOnloadCallbackName] = resolve;
    appendRecaptchaScript();
  });
});

/**
 * Clears the cached memoization of the default manager.
 *
 * This is needed for determinism in tests.
 */
export const clearMemoizeCache = () => {
  initRecaptchaScript.cache.clear();
};

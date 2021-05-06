import Vue from 'vue';
import CreditCardVerificationRequiredCallout from 'ee/billings/components/cc_verification_required_callout.vue';

export default (containerId = 'js-cc-verification-required-callout') => {
  const el = document.getElementById(containerId);

  if (!el) {
    return false;
  }

  const { containerClass } = el.dataset;

  return new Vue({
    el,
    render(createElement) {
      return createElement(CreditCardVerificationRequiredCallout, {
        props: {
          ...el.dataset,
          containerClass: JSON.parse(containerClass),
        },
      });
    },
  });
};

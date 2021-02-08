import Vue from 'vue';
import IssuableByEmail from './components/issuable_by_email.vue';

export default () => {
  const el = document.querySelector('.js-issueable-by-email');

  console.log('initIssuableByEmail');

  if (!el) return null;

  const {
    email,
    issuableType,
    emailsHelpPagePath,
    quickActionsHelpPath,
    markdownHelpPath,
    resetPath,
  } = el.dataset;

  return new Vue({
    el,
    provide: {
      email,
      issuableType,
      emailsHelpPagePath,
      quickActionsHelpPath,
      markdownHelpPath,
      resetPath,
    },
    render(h) {
      return h(IssuableByEmail);
    },
  });
};

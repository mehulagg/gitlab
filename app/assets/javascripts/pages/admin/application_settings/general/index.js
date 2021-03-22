import Vue from 'vue';
import IntegrationHelpText from '~/vue_shared/components/integrations_help_text.vue';
import initUserInternalRegexPlaceholder from '../account_and_limits';
import SignupForm from './signup_form.vue';

(() => {
  function mountGitpodSettings() {
    const el = document.querySelector('#js-gitpod-settings-help-text');

    if (!el) {
      return false;
    }

    const { message, messageUrl } = el.dataset;

    return new Vue({
      el,
      render(createElement) {
        return createElement(IntegrationHelpText, {
          props: {
            message,
            messageUrl,
          },
        });
      },
    });
  }

  function mountSignupForm() {
    const el = document.querySelector('#js-signup-form');

    if (!el) {
      return false;
    }

    return new Vue({
      el,
      render: (createElement) => createElement(SignupForm, { props: { ...el.dataset } }),
    });
  }

  initUserInternalRegexPlaceholder();
  mountGitpodSettings();
  mountSignupForm();
})();

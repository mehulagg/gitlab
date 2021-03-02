// This is a true violation of @gitlab/no-runtime-template-compiler, as it
// relies on app/views/admin/application_settings/_gitpod.html.haml for its
// template.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import Vue from 'vue';
import IntegrationHelpText from '~/vue_shared/components/integrations_help_text.vue';
import initUserInternalRegexPlaceholder from '../account_and_limits';
import SignupModal from './signup_modal.vue';

function mountGitpodSettings() {
  const el = document.querySelector('#js-gitpod-settings-help-text');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    name: 'GitpodSettings',
    components: {
      IntegrationHelpText,
    },
  });
}

function mountSignupModal() {
  const el = document.querySelector('#js-signup-modal');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    name: 'SignupSettings',
    render: (createElement) => createElement(SignupModal),
  });
}

initUserInternalRegexPlaceholder();
mountGitpodSettings();
mountSignupModal();

import $ from 'jquery';
import dirtySubmitFactory from '~/dirty_submit/dirty_submit_factory';
import { __ } from '~/locale';
import { fixTitle } from '~/tooltips';

const CALLOUT_SELECTOR = '.js-callout';
const HELPER_SELECTOR = '.js-helper-text';

function getHelperText(el) {
  return el.parentNode.querySelector(HELPER_SELECTOR);
}

function getCallout(el) {
  return el.parentNode.querySelector(CALLOUT_SELECTOR);
}

export default class SamlSettingsForm {
  constructor(formSelector) {
    this.form = document.querySelector(formSelector);
    this.settings = [
      {
        name: 'group-saml',
        el: this.form.querySelector('.js-group-saml-enabled-input'),
      },
      {
        name: 'enforced-sso',
        el: this.form.querySelector('.js-group-saml-enforced-sso-input'),
        dependsOn: 'group-saml',
      },
      {
        name: 'enforced-group-managed-accounts',
        el: this.form.querySelector('.js-group-saml-enforced-group-managed-accounts-input'),
        dependsOn: 'enforced-sso',
      },
      {
        name: 'enforced-git-activity-check',
        el: this.form.querySelector('.js-group-saml-enforced-git-check-input'),
        dependsOn: 'enforced-sso',
      },
      {
        name: 'prohibited-outer-forks',
        el: this.form.querySelector('.js-group-saml-prohibited-outer-forks-input'),
        dependsOn: 'enforced-group-managed-accounts',
      },
    ]
      .filter((s) => s.el)
      .map((setting) => ({
        ...setting,
        helperText: getHelperText(setting.el),
        callout: getCallout(setting.el),
      }));

    this.testButtonTooltipWrapper = this.form.querySelector('#js-saml-test-button');
    this.testButton = this.testButtonTooltipWrapper.querySelector('a');
    this.testButtonDisabled = this.testButtonTooltipWrapper.querySelector('button');
    this.dirtyFormChecker = dirtySubmitFactory(this.form, this.handleInputChange);
  }

  findSetting(name) {
    return this.settings.find((s) => s.name === name);
  }

  getValueWithDeps(name) {
    const setting = this.findSetting(name);
    let currentDependsOn = setting.dependsOn;

    while (currentDependsOn) {
      const { value, dependsOn } = this.findSetting(currentDependsOn);
      if (!value) {
        return false;
      }
      currentDependsOn = dependsOn;
    }

    return setting.value;
  }

  init() {
    this.updateSAMLSettings();
    this.updateView();
  }

  handleInputChange = () => {
    this.updateSAMLSettings();
    this.updateView();
  };

  formIsDirty() {
    return this.dirtyFormChecker.dirtyInputs.length;
  }

  updateSAMLSettings() {
    this.settings = this.settings.map((setting) => ({
      ...setting,
      value: setting.el.checked,
    }));
  }

  groupSamlEnabled() {
    return this.findSetting('group-saml').el.checked;
  }

  testButtonTooltip() {
    if (!this.groupSamlEnabled()) {
      return __('Group SAML must be enabled to test');
    }

    if (this.formIsDirty()) {
      return __('Save changes before testing');
    }

    return __('Redirect to SAML provider to test configuration');
  }

  updateCheckboxes() {
    this.settings
      .filter((setting) => setting.dependsOn)
      .forEach((setting) => {
        const { helperText, callout, el } = setting;
        const isRelatedToggleOn = this.getValueWithDeps(setting.dependsOn);
        if (helperText) {
          helperText.style.display = isRelatedToggleOn ? 'none' : 'block';
        }

        el.disabled = !isRelatedToggleOn;

        if (callout) {
          callout.style.display = setting.value && isRelatedToggleOn ? 'block' : 'none';
        }
      });
  }

  handleTestButtonClick = (event) => {
    event.preventDefault();
  };

  disableTestButton() {
    this.testButtonDisabled.removeAttribute('style');
    this.testButton.style.display = 'none';
  }

  enableTestButton() {
    this.testButton.removeAttribute('style');
    this.testButtonDisabled.style.display = 'none';
  }

  updateView() {
    if (this.getValueWithDeps('group-saml') && !this.formIsDirty()) {
      console.log('test');
      this.enableTestButton();
    } else {
      this.disableTestButton();
    }

    this.updateCheckboxes();

    // Update tooltip using wrapper so it works when input disabled
    this.testButtonTooltipWrapper.setAttribute('title', this.testButtonTooltip());

    fixTitle($(this.testButtonTooltipWrapper));
  }
}

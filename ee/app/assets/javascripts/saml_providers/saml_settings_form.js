import $ from 'jquery';
import { __ } from '~/locale';
import setupToggleButtons from '~/toggle_buttons';
import { parseBoolean } from '~/lib/utils/common_utils';
import { fixTitle } from '~/tooltips';
import DirtyFormChecker from './dirty_form_checker';

const CALLOUT_SELECTOR = '.js-callout';
const HELPER_SELECTOR = '.js-helper-text';
const TOGGLE_SELECTOR = '.js-project-feature-toggle';

function getHelperText(el) {
  return el.parentNode.querySelector(HELPER_SELECTOR);
}

function getCallout(el) {
  return el.parentNode.querySelector(CALLOUT_SELECTOR);
}

function getToggle(el) {
  return el.querySelector(TOGGLE_SELECTOR);
}

export default class SamlSettingsForm {
  constructor(formSelector) {
    this.form = document.querySelector(formSelector);
    this.settings = [
      {
        name: 'group-saml',
        el: this.form.querySelector('.js-group-saml-enabled-toggle-area'),
      },
      {
        name: 'enforced-sso',
        el: this.form.querySelector('.js-group-saml-enforced-sso-toggle-area'),
        dependsOn: 'group-saml',
      },
      {
        name: 'enforced-group-managed-accounts',
        el: this.form.querySelector('.js-group-saml-enforced-group-managed-accounts-toggle-area'),
        dependsOn: 'enforced-sso',
      },
      {
        name: 'prohibited-outer-forks',
        el: this.form.querySelector('.js-group-saml-prohibited-outer-forks-toggle-area'),
        dependsOn: 'enforced-group-managed-accounts',
      },
    ]
      .filter((s) => s.el)
      .map((setting) => ({
        ...setting,
        toggle: getToggle(setting.el),
        helperText: getHelperText(setting.el),
        callout: getCallout(setting.el),
        input: setting.el.querySelector('input'),
      }));

    this.testButtonTooltipWrapper = this.form.querySelector('#js-saml-test-button');
    this.testButton = this.testButtonTooltipWrapper.querySelector('a');
    this.dirtyFormChecker = new DirtyFormChecker(formSelector, () => this.updateView());
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
    this.dirtyFormChecker.init();
    setupToggleButtons(this.form);
    $(this.form).on('trigger-change', () => this.onEnableToggle());
    this.updateSAMLSettings();
    this.updateView();
  }

  onEnableToggle() {
    this.updateSAMLSettings();
    this.updateView();
  }

  updateSAMLSettings() {
    this.settings = this.settings.map((setting) => ({
      ...setting,
      value: parseBoolean(setting.el.querySelector('input').value),
    }));
  }

  testButtonTooltip() {
    if (!this.samlProviderEnabled) {
      return __('Group SAML must be enabled to test');
    }

    if (this.dirtyFormChecker.isDirty) {
      return __('Save changes before testing');
    }

    return __('Redirect to SAML provider to test configuration');
  }

  updateToggles() {
    this.settings
      .filter((setting) => setting.dependsOn)
      .forEach((setting) => {
        const { helperText, callout, toggle } = setting;
        const isRelatedToggleOn = this.getValueWithDeps(setting.dependsOn);
        if (helperText) {
          helperText.style.display = isRelatedToggleOn ? 'none' : 'block';
        }

        toggle.classList.toggle('is-disabled', !isRelatedToggleOn);
        toggle.disabled = !isRelatedToggleOn;

        if (callout) {
          callout.style.display = setting.value && isRelatedToggleOn ? 'block' : 'none';
        }
      });
  }

  updateView() {
    if (this.getValueWithDeps('group-saml') && !this.dirtyFormChecker.isDirty) {
      this.testButton.removeAttribute('disabled');
    } else {
      this.testButton.setAttribute('disabled', true);
    }

    this.updateToggles();

    // Update tooltip using wrapper so it works when input disabled
    this.testButtonTooltipWrapper.setAttribute('title', this.testButtonTooltip());

    fixTitle($(this.testButtonTooltipWrapper));
  }
}

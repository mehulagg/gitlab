import { within, fireEvent } from '@testing-library/dom';
import SamlSettingsForm from 'ee/saml_providers/saml_settings_form';
import 'bootstrap';

describe('SamlSettingsForm', () => {
  const FIXTURE = 'groups/saml_providers/show.html';

  let samlSettingsForm;
  beforeEach(() => {
    loadFixtures(FIXTURE);
    samlSettingsForm = new SamlSettingsForm('.js-saml-settings-form');
    samlSettingsForm.init();
  });

  const findEnforcedGroupManagedAccountSetting = () =>
    samlSettingsForm.settings.find((s) => s.name === 'enforced-group-managed-accounts');
  const findProhibitForksSetting = () =>
    samlSettingsForm.settings.find((s) => s.name === 'prohibited-outer-forks');

  const getEnableSamlAuthenticationCheckbox = () =>
    within(document).getByLabelText('Enable SAML authentication for this group.');
  const getProviderUrlInput = () =>
    within(document).getByLabelText('Identity provider single sign-on URL');

  const expectTestButtonEnabled = () => {
    expect(samlSettingsForm.testButton.hasAttribute('style')).toBe(false);
    expect(samlSettingsForm.testButtonDisabled.style.display).toBe('none');
  };
  const expectTestButtonDisabled = () => {
    expect(samlSettingsForm.testButton.style.display).toBe('none');
    expect(samlSettingsForm.testButtonDisabled.hasAttribute('style')).toBe(false);
  };

  describe('updateView', () => {
    it('disables `Verify SAML Configuration` button when form has changes', () => {
      expectTestButtonEnabled();

      fireEvent.input(getProviderUrlInput(), { target: { value: 'foo bar' } });

      expectTestButtonDisabled();
    });

    it('re-enables `Verify SAML Configuration` button when form is returned to starting state', () => {
      const providerUrlInput = getProviderUrlInput();
      const providerUrlValue = providerUrlInput.value;

      expectTestButtonEnabled();

      fireEvent.input(getProviderUrlInput(), { target: { value: 'foo bar' } });

      expectTestButtonDisabled();

      fireEvent.input(getProviderUrlInput(), { target: { value: providerUrlValue } });

      expectTestButtonEnabled();
    });

    it('disables `Verify SAML Configuration` button when SAML disabled for the group', () => {
      expectTestButtonEnabled();

      fireEvent.click(getEnableSamlAuthenticationCheckbox());

      expectTestButtonDisabled();
    });
  });

  it('correctly disables dependent checkboxes', () => {
    samlSettingsForm.settings.forEach((s) => {
      const { el } = s;
      el.checked = true;
    });

    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();
    expect(findProhibitForksSetting().el.hasAttribute('disabled')).toBe(false);

    findEnforcedGroupManagedAccountSetting().el.checked = false;
    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();

    expect(findProhibitForksSetting().el.hasAttribute('disabled')).toBe(true);
    expect(findProhibitForksSetting().value).toBe(true);
  });

  it('correctly disables multiple dependent toggles', () => {
    samlSettingsForm.settings.forEach((s) => {
      const { el } = s;
      el.checked = true;
    });

    let groupSamlSetting;
    let otherSettings;

    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();
    [groupSamlSetting, ...otherSettings] = samlSettingsForm.settings;
    expect(samlSettingsForm.settings.every((s) => s.value)).toBe(true);
    expect(samlSettingsForm.settings.some((s) => s.el.hasAttribute('disabled'))).toBe(false);

    groupSamlSetting.el.checked = false;
    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();

    return new Promise(window.requestAnimationFrame).then(() => {
      [groupSamlSetting, ...otherSettings] = samlSettingsForm.settings;
      expect(otherSettings.every((s) => s.value)).toBe(true);
      expect(otherSettings.every((s) => s.el.hasAttribute('disabled'))).toBe(true);
    });
  });
});

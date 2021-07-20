import SamlSettingsForm from 'ee/saml_providers/saml_settings_form';
import 'bootstrap';

describe('SamlSettingsForm', () => {
  const FIXTURE = 'groups/saml_providers/show.html';

  let samlSettingsForm;
  beforeEach(() => {
    loadFixtures(FIXTURE);
    samlSettingsForm = new SamlSettingsForm('#js-saml-settings-form');
    samlSettingsForm.init();
  });

  const findEnforcedGroupManagedAccountSetting = () =>
    samlSettingsForm.settings.find((s) => s.name === 'enforced-group-managed-accounts');
  const findEnforcedSsoSetting = () =>
    samlSettingsForm.settings.find((s) => s.name === 'enforced-sso');
  const findProhibitForksSetting = () =>
    samlSettingsForm.settings.find((s) => s.name === 'prohibited-outer-forks');

  describe('updateView', () => {
    it('disables Test button when form has changes', () => {
      samlSettingsForm.dirtyFormChecker.dirtyInputs = [findEnforcedGroupManagedAccountSetting().el];

      expect(samlSettingsForm.testButton.hasAttribute('disabled')).toBe(false);

      samlSettingsForm.updateView();

      expect(samlSettingsForm.testButton.hasAttribute('disabled')).toBe(true);
    });

    it('re-enables Test button when form is returned to starting state', () => {
      samlSettingsForm.testButton.setAttribute('disabled', true);

      samlSettingsForm.updateView();

      expect(samlSettingsForm.testButton.hasAttribute('disabled')).toBe(false);
    });

    it('keeps Test button disabled when SAML disabled for the group', () => {
      samlSettingsForm.settings.find((s) => s.name === 'group-saml').value = false;
      samlSettingsForm.testButton.setAttribute('disabled', true);

      samlSettingsForm.updateView();

      expect(samlSettingsForm.testButton.hasAttribute('disabled')).toBe(true);
    });
  });

  it('correctly disables dependent toggle and shows helper text', () => {
    samlSettingsForm.settings.forEach((s) => {
      const { el } = s;
      el.checked = true;
    });

    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();
    expect(findProhibitForksSetting().el.hasAttribute('disabled')).toBe(false);
    expect(findProhibitForksSetting().helperText.classList.contains('gl-display-none')).toBe(true);

    findEnforcedGroupManagedAccountSetting().el.checked = false;
    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();

    expect(findProhibitForksSetting().el.hasAttribute('disabled')).toBe(true);
    expect(findProhibitForksSetting().helperText.classList.contains('gl-display-none')).toBe(false);
    expect(findProhibitForksSetting().value).toBe(true);
  });

  it('correctly shows warning text when checkbox is unchecked', () => {
    expect(findEnforcedSsoSetting().warning.classList.contains('gl-display-none')).toBe(true);

    findEnforcedSsoSetting().el.checked = false;
    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();

    expect(findEnforcedSsoSetting().warning.classList.contains('gl-display-none')).toBe(false);
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

    [groupSamlSetting, ...otherSettings] = samlSettingsForm.settings;
    expect(otherSettings.every((s) => s.value)).toBe(true);
    expect(otherSettings.every((s) => s.el.hasAttribute('disabled'))).toBe(true);
  });
});

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

  describe('updateView', () => {
    it('disables Test button when form has changes', () => {
      samlSettingsForm.dirtyFormChecker.isDirty = true;

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

  it('correctly disables dependent toggle', () => {
    samlSettingsForm.settings.forEach((s) => {
      const { input } = s;
      input.value = true;
    });

    const findEnforcedGroupManagedAccountSetting = () =>
      samlSettingsForm.settings.find((s) => s.name === 'enforced-group-managed-accounts');
    const findProhibitForksSetting = () =>
      samlSettingsForm.settings.find((s) => s.name === 'prohibited-outer-forks');

    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();
    expect(findProhibitForksSetting().toggle.hasAttribute('disabled')).toBe(false);
    expect(findProhibitForksSetting().toggle.classList.contains('is-disabled')).toBe(false);

    findEnforcedGroupManagedAccountSetting().input.value = false;
    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();

    expect(findProhibitForksSetting().toggle.hasAttribute('disabled')).toBe(true);
    expect(findProhibitForksSetting().toggle.classList.contains('is-disabled')).toBe(true);
    expect(findProhibitForksSetting().value).toBe(true);
  });

  it('correctly disables multiple dependent toggles', () => {
    samlSettingsForm.settings.forEach((s) => {
      const { input } = s;
      input.value = true;
    });

    let groupSamlSetting;
    let otherSettings;

    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();
    [groupSamlSetting, ...otherSettings] = samlSettingsForm.settings;
    expect(samlSettingsForm.settings.every((s) => s.value)).toBe(true);
    expect(samlSettingsForm.settings.some((s) => s.toggle.hasAttribute('disabled'))).toBe(false);

    groupSamlSetting.input.value = false;
    samlSettingsForm.updateSAMLSettings();
    samlSettingsForm.updateView();

    return new Promise(window.requestAnimationFrame).then(() => {
      [groupSamlSetting, ...otherSettings] = samlSettingsForm.settings;
      expect(otherSettings.every((s) => s.value)).toBe(true);
      expect(otherSettings.every((s) => s.toggle.hasAttribute('disabled'))).toBe(true);
    });
  });
});

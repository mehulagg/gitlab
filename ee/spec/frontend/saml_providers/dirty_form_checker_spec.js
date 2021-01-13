import DirtyFormChecker from 'ee/saml_providers/dirty_form_checker';

describe('DirtyFormChecker', () => {
  const FIXTURE = 'groups/saml_providers/show.html';

  beforeEach(() => {
    loadFixtures(FIXTURE);
  });

  describe('constructor', () => {
    let dirtyFormChecker;

    beforeEach(() => {
      dirtyFormChecker = new DirtyFormChecker('#js-saml-settings-form');
    });

    it('finds editable inputs', () => {
      const editableInputs = dirtyFormChecker.editableInputs.map((input) => input.name);

      expect(editableInputs).toContain('saml_provider[sso_url]');
      expect(editableInputs).not.toContain('authenticity_token');
    });

    it('tracks starting states for editable inputs', () => {
      const enabledStartState = dirtyFormChecker.startingStates['saml_provider[enabled]'];

      expect(enabledStartState).toEqual('true');
    });
  });

  describe('recalculate', () => {
    let dirtyFormChecker;
    let onChangeCallback;

    beforeEach(() => {
      onChangeCallback = jest.fn();
      dirtyFormChecker = new DirtyFormChecker('#js-saml-settings-form', onChangeCallback);
    });

    it('does not trigger callback when nothing changes', () => {
      dirtyFormChecker.recalculate();

      expect(onChangeCallback).not.toHaveBeenCalled();
    });

    it('triggers callback when form becomes dirty', () => {
      dirtyFormChecker.startingStates['saml_provider[sso_url]'] = 'https://old.value';
      dirtyFormChecker.recalculate();

      expect(dirtyFormChecker.isDirty).toEqual(true);
      expect(onChangeCallback).toHaveBeenCalled();
    });

    it('triggers callback when form returns to original state', () => {
      dirtyFormChecker.isDirty = true;
      dirtyFormChecker.recalculate();

      expect(onChangeCallback).toHaveBeenCalled();
    });
  });
});

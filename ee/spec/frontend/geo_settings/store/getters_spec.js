import * as getters from 'ee/geo_settings/store/getters';
import createState from 'ee/geo_settings/store/state';

describe('Geo Settings Store Getters', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('formHasError', () => {
    it('with error returns true', () => {
      state.formErrors.timeout = 'Error';

      expect(getters.formHasError(state)).toBeTruthy();
    });

    it('without error returns false', () => {
      state.formErrors.timeout = '';

      expect(getters.formHasError(state)).toBeFalsy();
    });
  });
});

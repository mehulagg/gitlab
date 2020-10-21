import * as types from 'ee/security_configuration/modules/configuration/mutation_types';
import mutations from 'ee/security_configuration/modules/configuration/mutations';

describe('security configuration module mutations', () => {
  let state;

  beforeEach(() => {
    state = {};
  });

  describe('REQUEST_SECURITY_CONFIGURATION', () => {
    it('should set the isLoading to true', () => {
      mutations[types.REQUEST_SECURITY_CONFIGURATION](state);
      expect(state.isLoading).toBe(true);
      expect(state.errorLoading).toBe(false);
    });
  });

  describe('RECEIVE_SECURITY_CONFIGURATION_SUCCESS', () => {
    it('should set the isLoading to false and configuration to the response object', () => {
      const configuration = {};
      mutations[types.RECEIVE_SECURITY_CONFIGURATION_SUCCESS](state, configuration);
      expect(state.isLoading).toBe(false);
      expect(state.errorLoading).toBe(false);
      expect(state.configuration).toBe(configuration);
    });
  });

  describe('RECEIVE_SECURITY_CONFIGURATION_ERROR', () => {
    it('should set the isLoading to false', () => {
      mutations[types.RECEIVE_SECURITY_CONFIGURATION_ERROR](state);
      expect(state.isLoading).toBe(false);
      expect(state.errorLoading).toBe(true);
    });
  });
});

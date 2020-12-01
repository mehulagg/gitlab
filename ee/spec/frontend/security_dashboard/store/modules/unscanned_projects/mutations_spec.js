import * as types from 'ee/security_dashboard/store/modules/unscanned_projects/mutation_types';
import mutations from 'ee/security_dashboard/store/modules/unscanned_projects/mutations';
import createState from 'ee/security_dashboard/store/modules/unscanned_projects/state';

describe('unscannedProjects mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('REQUEST_UNSCANNED_PROJECTS', () => {
    it('sets state.isLoading to be "true"', () => {
      state.isLoading = false;

      mutations[types.REQUEST_UNSCANNED_PROJECTS](state, true);

      expect(state.isLoading).toBe(true);
    });
  });

  describe('RECEIVE_UNSCANNED_PROJECTS_SUCCESS', () => {
    it('sets state.isLoading to be "false"', () => {
      state.isLoading = true;
      const payload = [];

      mutations[types.RECEIVE_UNSCANNED_PROJECTS_SUCCESS](state, payload);

      expect(state.isLoading).toBe(false);
    });

    it('sets state.projects to the given payload', () => {
      const payload = [];

      mutations[types.RECEIVE_UNSCANNED_PROJECTS_SUCCESS](state, payload);

      expect(state.projects).toBe(payload);
    });
  });

  describe('RECEIVE_UNSCANNED_PROJECTS_ERROR', () => {
    it('sets state.isLoading to be "false"', () => {
      state.isLoading = true;

      mutations[types.RECEIVE_UNSCANNED_PROJECTS_ERROR](state);

      expect(state.isLoading).toBe(false);
    });
  });
});

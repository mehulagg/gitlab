import * as types from 'ee/security_dashboard/store/modules/projects/mutation_types';
import mutations from 'ee/security_dashboard/store/modules/projects/mutations';
import createState from 'ee/security_dashboard/store/modules/projects/state';
import mockData from './data/mock_data.json';

describe('projects module mutations', () => {
  describe('SET_PROJECTS_ENDPOINT', () => {
    it('should set `projectsEndpoint` to `fakepath.json`', () => {
      const state = createState();
      const endpoint = 'fakepath.json';

      mutations[types.SET_PROJECTS_ENDPOINT](state, endpoint);

      expect(state.projectsEndpoint).toEqual(endpoint);
    });
  });

  describe('REQUEST_PROJECTS', () => {
    let state;

    beforeEach(() => {
      state = {
        ...createState(),
        errorLoadingProjects: true,
      };
      mutations[types.REQUEST_PROJECTS](state);
    });

    it('should set `isLoadingProjects` to `true`', () => {
      expect(state.isLoadingProjects).toBe(true);
    });

    it('should set `errorLoadingProjects` to `false`', () => {
      expect(state.errorLoadingProjects).toBe(false);
    });
  });

  describe('RECEIVE_PROJECTS_SUCCESS', () => {
    let payload;
    let state;

    beforeEach(() => {
      payload = {
        projects: mockData,
      };
      state = createState();
      mutations[types.RECEIVE_PROJECTS_SUCCESS](state, payload);
    });

    it('should set `isLoadingProjects` to `false`', () => {
      expect(state.isLoadingProjects).toBe(false);
    });

    it('should set `pageInfo`', () => {
      expect(state.pageInfo).toBe(payload.pageInfo);
    });

    it('should set `projects`', () => {
      expect(state.projects).toBe(payload.projects);
    });
  });

  describe('RECEIVE_PROJECTS_ERROR', () => {
    it('should set `isLoadingProjects` to `false`', () => {
      const state = createState();

      mutations[types.RECEIVE_PROJECTS_ERROR](state);

      expect(state.isLoadingProjects).toBe(false);
    });
  });
});

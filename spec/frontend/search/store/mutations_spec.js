import { GROUPS_LOCAL_STORAGE_KEY, PROJECTS_LOCAL_STORAGE_KEY } from '~/search/store/constants';
import * as types from '~/search/store/mutation_types';
import mutations from '~/search/store/mutations';
import createState from '~/search/store/state';
import { MOCK_QUERY, MOCK_GROUPS, MOCK_PROJECTS } from '../mock_data';

describe('Global Search Store Mutations', () => {
  let state;

  beforeEach(() => {
    state = createState({ query: MOCK_QUERY });
  });

  describe('REQUEST_GROUPS', () => {
    it('sets fetchingGroups to true', () => {
      mutations[types.REQUEST_GROUPS](state);

      expect(state.fetchingGroups).toBe(true);
    });
  });

  describe('RECEIVE_GROUPS_SUCCESS', () => {
    it('sets fetchingGroups to false and sets groups', () => {
      mutations[types.RECEIVE_GROUPS_SUCCESS](state, MOCK_GROUPS);

      expect(state.fetchingGroups).toBe(false);
      expect(state.groups).toBe(MOCK_GROUPS);
    });
  });

  describe('RECEIVE_GROUPS_ERROR', () => {
    it('sets fetchingGroups to false and clears groups', () => {
      mutations[types.RECEIVE_GROUPS_ERROR](state);

      expect(state.fetchingGroups).toBe(false);
      expect(state.groups).toEqual([]);
    });
  });

  describe('REQUEST_FREQUENT_GROUPS', () => {
    it('sets fetchingGroups to true', () => {
      mutations[types.REQUEST_FREQUENT_GROUPS](state);

      expect(state.fetchingFrequentGroups).toBe(true);
    });
  });

  describe('RECEIVE_FREQUENT_GROUPS_SUCCESS', () => {
    it('sets fetchingGroups to false and sets groups', () => {
      mutations[types.RECEIVE_FREQUENT_GROUPS_SUCCESS](state, MOCK_GROUPS);

      expect(state.fetchingFrequentGroups).toBe(false);
      expect(state.frequentItems[GROUPS_LOCAL_STORAGE_KEY]).toStrictEqual(MOCK_GROUPS);
    });
  });

  describe('RECEIVE_FREQUENT_GROUPS_ERROR', () => {
    it('sets fetchingGroups to false and clears groups', () => {
      mutations[types.RECEIVE_FREQUENT_GROUPS_ERROR](state);

      expect(state.fetchingFrequentGroups).toBe(false);
      expect(state.frequentItems[GROUPS_LOCAL_STORAGE_KEY]).toStrictEqual([]);
    });
  });

  describe('REQUEST_PROJECTS', () => {
    it('sets fetchingProjects to true', () => {
      mutations[types.REQUEST_PROJECTS](state);

      expect(state.fetchingProjects).toBe(true);
    });
  });

  describe('RECEIVE_PROJECTS_SUCCESS', () => {
    it('sets fetchingProjects to false and sets projects', () => {
      mutations[types.RECEIVE_PROJECTS_SUCCESS](state, MOCK_PROJECTS);

      expect(state.fetchingProjects).toBe(false);
      expect(state.projects).toBe(MOCK_PROJECTS);
    });
  });

  describe('RECEIVE_PROJECTS_ERROR', () => {
    it('sets fetchingProjects to false and clears projects', () => {
      mutations[types.RECEIVE_PROJECTS_ERROR](state);

      expect(state.fetchingProjects).toBe(false);
      expect(state.projects).toEqual([]);
    });
  });

  describe('REQUEST_FREQUENT_PROJECTS', () => {
    it('sets fetchingGroups to true', () => {
      mutations[types.REQUEST_FREQUENT_PROJECTS](state);

      expect(state.fetchingFrequentProjects).toBe(true);
    });
  });

  describe('RECEIVE_FREQUENT_PROJECTS_SUCCESS', () => {
    it('sets fetchingGroups to false and sets groups', () => {
      mutations[types.RECEIVE_FREQUENT_PROJECTS_SUCCESS](state, MOCK_PROJECTS);

      expect(state.fetchingFrequentProjects).toBe(false);
      expect(state.frequentItems[PROJECTS_LOCAL_STORAGE_KEY]).toStrictEqual(MOCK_PROJECTS);
    });
  });

  describe('RECEIVE_FREQUENT_PROJECTS_ERROR', () => {
    it('sets fetchingGroups to false and clears groups', () => {
      mutations[types.RECEIVE_FREQUENT_PROJECTS_ERROR](state);

      expect(state.fetchingFrequentProjects).toBe(false);
      expect(state.frequentItems[PROJECTS_LOCAL_STORAGE_KEY]).toStrictEqual([]);
    });
  });

  describe('SET_QUERY', () => {
    const payload = { key: 'key1', value: 'value1' };

    it('sets query key to value', () => {
      mutations[types.SET_QUERY](state, payload);

      expect(state.query[payload.key]).toBe(payload.value);
    });
  });
});

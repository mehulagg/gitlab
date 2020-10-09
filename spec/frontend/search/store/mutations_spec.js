import mutations from '~/search/store/mutations';
import createState from '~/search/store/state';
import * as types from '~/search/store/mutation_types';
import { MOCK_QUERY, MOCK_GROUP, MOCK_GROUPS } from '../mock_data';

describe('Global Search Store Mutations', () => {
  let state;

  beforeEach(() => {
    state = createState({ query: MOCK_QUERY });
  });

  describe('REQUEST_INITIAL_GROUP', () => {
    it('sets fetchingInitialGroup to true', () => {
      mutations[types.REQUEST_INITIAL_GROUP](state);

      expect(state.fetchingInitialGroup).toBe(true);
    });
  });

  describe('RECEIVE_INITIAL_GROUP_SUCCESS', () => {
    it('sets fetchingInitialGroup to false and sets initialGroup', () => {
      mutations[types.RECEIVE_INITIAL_GROUP_SUCCESS](state, MOCK_GROUP);

      expect(state.fetchingInitialGroup).toBe(false);
      expect(state.initialGroup).toBe(MOCK_GROUP);
    });
  });

  describe('RECEIVE_INITIAL_GROUP_ERROR', () => {
    it('sets fetchingInitialGroup to false and clears initialGroup', () => {
      mutations[types.RECEIVE_INITIAL_GROUP_ERROR](state);

      expect(state.fetchingInitialGroup).toBe(false);
      expect(state.initialGroup).toBe(null);
    });
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
});

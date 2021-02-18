import * as types from 'ee/geo_nodes_beta/store/mutation_types';
import mutations from 'ee/geo_nodes_beta/store/mutations';
import createState from 'ee/geo_nodes_beta/store/state';
import { MOCK_PRIMARY_VERSION, MOCK_REPLICABLE_TYPES, MOCK_NODES } from '../mock_data';

describe('GeoNodesBeta Store Mutations', () => {
  let state;
  beforeEach(() => {
    state = createState({
      primaryVersion: MOCK_PRIMARY_VERSION.version,
      primaryRevision: MOCK_PRIMARY_VERSION.revision,
      replicableTypes: MOCK_REPLICABLE_TYPES,
    });
  });

  describe('REQUEST_NODES', () => {
    it('sets isLoading to true', () => {
      mutations[types.REQUEST_NODES](state);

      expect(state.isLoading).toBe(true);
    });
  });

  describe('RECEIVE_NODES_SUCCESS', () => {
    beforeEach(() => {
      state.isLoading = true;
    });

    it('sets nodes and ends loading', () => {
      mutations[types.RECEIVE_NODES_SUCCESS](state, MOCK_NODES);

      expect(state.isLoading).toBe(false);
      expect(state.nodes).toEqual(MOCK_NODES);
    });
  });

  describe('RECEIVE_NODES_ERROR', () => {
    beforeEach(() => {
      state.isLoading = true;
      state.nodes = MOCK_NODES;
    });

    it('resets state', () => {
      mutations[types.RECEIVE_NODES_ERROR](state);

      expect(state.isLoading).toBe(false);
      expect(state.nodes).toEqual([]);
    });
  });
});

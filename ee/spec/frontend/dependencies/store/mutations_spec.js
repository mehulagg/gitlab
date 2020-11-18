import { DEPENDENCY_LIST_TYPES } from 'ee/dependencies/store/constants';
import * as types from 'ee/dependencies/store/mutation_types';
import mutations from 'ee/dependencies/store/mutations';
import getInitialState from 'ee/dependencies/store/state';

describe('Dependencies mutations', () => {
  let state;

  beforeEach(() => {
    state = getInitialState();
  });

  describe(types.ADD_LIST_TYPE, () => {
    it('adds the given module type to the list of modules', () => {
      const typeToAdd = DEPENDENCY_LIST_TYPES.vulnerable;
      mutations[types.ADD_LIST_TYPE](state, typeToAdd);

      const lastAdded = state.listTypes[state.listTypes.length - 1];
      expect(lastAdded).toEqual(typeToAdd);
    });
  });

  describe(types.SET_CURRENT_LIST, () => {
    it('sets the current list namespace', () => {
      const namespace = 'foobar';
      mutations[types.SET_CURRENT_LIST](state, namespace);

      expect(state.currentList).toBe(namespace);
    });
  });
});

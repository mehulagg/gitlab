import createState from 'ee/security_dashboard/store/modules/filters/state';
import * as getters from 'ee/security_dashboard/store/modules/filters/getters';

describe('filters module getters', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('activeFilters', () => {
    it('should return no severity filters', () => {
      const activeFilters = getters.activeFilters(state);

      expect(activeFilters.severity).toHaveLength(0);
    });

    it('should return multiple dummy filters"', () => {
      const dummyFilter = {
        id: 'dummy',
        options: [{ id: 'one' }, { id: 'two' }],
        selection: new Set(['one', 'two']),
      };
      state.filters.push(dummyFilter);
      const activeFilters = getters.activeFilters(state);

      expect(activeFilters.dummy).toHaveLength(2);
    });
  });
});

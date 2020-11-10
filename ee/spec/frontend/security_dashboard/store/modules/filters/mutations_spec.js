import createState from 'ee/security_dashboard/store/modules/filters/state';
import * as types from 'ee/security_dashboard/store/modules/filters/mutation_types';
import mutations from 'ee/security_dashboard/store/modules/filters/mutations';
import { severityFilter, scannerFilter } from 'ee/security_dashboard/helpers';

const criticalOption = severityFilter.options.find(x => x.id === 'CRITICAL');
const highOption = severityFilter.options.find(x => x.id === 'HIGH');

describe('filters module mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('SET_FILTER', () => {
    it.each`
      options
      ${[]}
      ${[criticalOption.id]}
      ${[criticalOption.id, highOption.id]}
    `('sets the filter to %o', ({ options }) => {
      mutations[types.SET_FILTER](state, { [severityFilter.id]: options });

      expect(state.filters[severityFilter.id]).toEqual(options);
    });

    it('sets multiple filters correctly', () => {
      const severities = { [severityFilter.id]: ['HIGH', 'LOW'] };
      const scanners = { [scannerFilter.id]: ['DAST', 'SAST'] };

      mutations[types.SET_FILTER](state, severities);
      mutations[types.SET_FILTER](state, scanners);

      expect(state.filters).toMatchObject({ ...severities, ...scanners });
    });
  });

  describe('TOGGLE_HIDE_DISMISSED', () => {
    it('toggles scope filter', () => {
      const toggleAndCheck = expected => {
        mutations[types.TOGGLE_HIDE_DISMISSED](state);
        expect(state.filters.scope).toBe(expected);
      };

      toggleAndCheck('all');
      toggleAndCheck('dismissed');
      toggleAndCheck('all');
    });
  });
});

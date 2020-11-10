import createState from 'ee/security_dashboard/store/modules/filters/state';
import * as types from 'ee/security_dashboard/store/modules/filters/mutation_types';
import mutations from 'ee/security_dashboard/store/modules/filters/mutations';
import { severityFilter } from 'ee/security_dashboard/helpers';

const criticalOption = severityFilter.options.find(x => x.id === 'CRITICAL');
const highOption = severityFilter.options.find(x => x.id === 'HIGH');

describe('filters module mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('SET_FILTER', () => {
    beforeEach(() => {
      mutations[types.SET_FILTER](state, {
        [severityFilter.id]: [criticalOption.id],
      });
    });

    it.each`
      options
      ${[]}
      ${[criticalOption.id]}
      ${[criticalOption.id, highOption.id]}
    `('should set the selected option to $options', ({ options }) => {
      mutations[types.SET_FILTER](state, { [severityFilter.id]: options });

      expect(state.filters[severityFilter.id]).toEqual(options);
    });
  });
});

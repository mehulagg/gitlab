import createStore from 'ee/security_dashboard/store/index';
import * as filtersMutationTypes from 'ee/security_dashboard/store/modules/filters/mutation_types';

function expectRefreshDispatches(store, payload) {
  expect(store.dispatch).toHaveBeenCalledTimes(3);
  expect(store.dispatch).toHaveBeenCalledWith('vulnerabilities/fetchVulnerabilities', payload);

  expect(store.dispatch).toHaveBeenCalledWith('vulnerabilities/fetchVulnerabilitiesCount', payload);

  expect(store.dispatch).toHaveBeenCalledWith(
    'vulnerabilities/fetchVulnerabilitiesHistory',
    payload,
  );
}

describe('mediator', () => {
  let store;

  beforeEach(() => {
    store = createStore();
    jest.spyOn(store, 'dispatch').mockImplementation(() => {});
  });

  it('triggers fetching vulnerabilities after one filter changes', () => {
    store.commit(`filters/${filtersMutationTypes.SET_FILTER}`, {});

    expectRefreshDispatches(store, store.state.filters.filters);
  });

  it('triggers fetching vulnerabilities after multiple filters change', () => {
    const payload = {
      ...store.state.filters.filters,
      page: store.state.vulnerabilities.pageInfo.page,
    };

    store.commit(`filters/${filtersMutationTypes.SET_FILTER}`, payload);

    expectRefreshDispatches(store, payload);
  });

  it('triggers fetching vulnerabilities after "Hide dismissed" toggle changes', () => {
    store.commit(`filters/${filtersMutationTypes.TOGGLE_HIDE_DISMISSED}`);

    expectRefreshDispatches(store, store.state.filters.filters);
  });
});

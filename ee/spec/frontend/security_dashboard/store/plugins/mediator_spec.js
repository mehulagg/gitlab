import createStore from 'ee/security_dashboard/store/index';
import * as filtersMutationTypes from 'ee/security_dashboard/store/modules/filters/mutation_types';
import * as vulnerabilityMutationTypes from 'ee/security_dashboard/store/modules/vulnerabilities/mutation_types';

function expectRefreshDispatches(store, payload) {
  expect(store.dispatch).toHaveBeenCalledTimes(2);
  expect(store.dispatch).toHaveBeenCalledWith('vulnerabilities/fetchVulnerabilities', payload);
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
    const activeFilters = store.getters['filters/activeFilters'];

    expectRefreshDispatches(store, activeFilters);
  });

  it('does not fetch vulnerabilities after one filter changes with lazy = true', () => {
    store.commit(`filters/${filtersMutationTypes.SET_FILTER}`, { lazy: true });

    expect(store.dispatch).not.toHaveBeenCalled();
  });

  it('triggers fetching vulnerabilities after filters change', () => {
    const payload = {
      ...store.getters['filters/activeFilters'],
      page: store.state.vulnerabilities.pageInfo.page,
    };

    store.commit(`filters/${filtersMutationTypes.SET_ALL_FILTERS}`, {});

    expectRefreshDispatches(store, payload);
  });

  it('triggers fetching vulnerabilities multiple vulnerabilities have been dismissed', () => {
    const activeFilters = store.getters['filters/activeFilters'];

    store.commit(
      `vulnerabilities/${vulnerabilityMutationTypes.RECEIVE_DISMISS_SELECTED_VULNERABILITIES_SUCCESS}`,
      {},
    );

    expectRefreshDispatches(store, activeFilters);
  });

  it('triggers fetching vulnerabilities after "Hide dismissed" toggle changes', () => {
    const activeFilters = store.getters['filters/activeFilters'];

    store.commit(`filters/${filtersMutationTypes.SET_TOGGLE_VALUE}`, {});

    expectRefreshDispatches(store, activeFilters);
  });

  it('does not fetch vulnerabilities after "Hide dismissed" toggle changes with lazy = true', () => {
    store.commit(`filters/${filtersMutationTypes.SET_TOGGLE_VALUE}`, { lazy: true });

    expect(store.dispatch).not.toHaveBeenCalled();
  });
});

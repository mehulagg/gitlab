import createStore from 'ee/status_checks/store';

describe('createStore', () => {
  it('creates a new store', () => {
    expect(createStore().state).toStrictEqual({
      isLoading: false,
      settings: {},
      statusChecks: [],
    });
  });
});

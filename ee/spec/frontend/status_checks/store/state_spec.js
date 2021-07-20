import initialState from 'ee/status_checks/store/state';

describe('state', () => {
  it('returns the expected default state', () => {
    expect(initialState()).toStrictEqual({
      isLoading: false,
      settings: {},
      statusChecks: [],
    });
  });
});

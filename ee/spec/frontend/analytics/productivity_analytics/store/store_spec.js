import store from 'ee/analytics/productivity_analytics/store';
import state from 'ee/analytics/productivity_analytics/store/state';

describe('Productivity analytics store', () => {
  it('exports an initialized store', () => {
    expect(store).toMatchObject({
      state: state(),
    });
  });
});

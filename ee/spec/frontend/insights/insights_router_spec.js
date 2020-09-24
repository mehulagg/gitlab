import createRouter from 'ee/insights/insights_router';
import store from 'ee/insights/stores';

describe('insights router', () => {
  let router;

  beforeEach(() => {
    router = createRouter('base');
  });

  it(`sets the activeTab when route changed`, () => {
    const route = 'route';

    jest.spyOn(store, 'dispatch').mockImplementation(() => {});

    router.push(`/${route}`);

    expect(store.dispatch).toHaveBeenCalledWith('insights/setActiveTab', route);
  });
});

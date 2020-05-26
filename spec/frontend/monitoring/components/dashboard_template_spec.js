import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import Dashboard from '~/monitoring/components/dashboard.vue';
import { createStore } from '~/monitoring/stores';
import { setupAllDashboards } from '../store_utils';
import { propsData } from '../mock_data';

jest.mock('~/lib/utils/url_utility');

describe('Dashboard template', () => {
  let wrapper;
  let store;
  let mock;

  beforeEach(() => {
    store = createStore({
      currentEnvironmentName: 'production',
    });
    mock = new MockAdapter(axios);

    setupAllDashboards(store);
  });

  afterEach(() => {
    mock.restore();
  });

  it('matches the default snapshot', () => {
    wrapper = shallowMount(Dashboard, { propsData: { ...propsData }, store });

    expect(wrapper.element).toMatchSnapshot();
  });
});

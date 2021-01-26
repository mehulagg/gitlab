import { shallowMount } from '@vue/test-utils';
import setWindowLocation from 'helpers/set_window_location_helper';
import { historyPushState } from '~/lib/utils/common_utils';
import { mergeUrlParams } from '~/lib/utils/url_utility';
import UrlSyncComponent from '~/vue_shared/components/url_sync.vue';

jest.mock('~/lib/utils/url_utility', () => ({
  mergeUrlParams: jest.fn((query, url) => `urlParams: ${query} ${url}`),
}));

jest.mock('~/lib/utils/common_utils', () => ({
  historyPushState: jest.fn(),
}));

describe('url sync component', () => {
  let wrapper;
  const mockQuery = { group_id: '5014437163714', project_ids: ['5014437608314'] };
  const TEST_HOST = 'http://testhost/';

  jest.mock();
  setWindowLocation(TEST_HOST);

  const createComponent = () => {
    wrapper = shallowMount(UrlSyncComponent, {
      propsData: { query: mockQuery },
    });
  };

  function expectUrlSync(query) {
    expect(mergeUrlParams).toHaveBeenCalledTimes(1);
    expect(mergeUrlParams).toHaveBeenCalledWith(query, TEST_HOST, { spreadArrays: true });

    const mergeUrlParamsReturnValue = mergeUrlParams.mock.results[0].value;
    expect(historyPushState).toHaveBeenCalledTimes(1);
    expect(historyPushState).toHaveBeenCalledWith(mergeUrlParamsReturnValue);
  }

  beforeEach(() => {
    createComponent();
  });

  it('immediately syncs the query to the URL', () => expectUrlSync(mockQuery));

  describe('when the query is modified', () => {
    const newQuery = { foo: true };
    beforeEach(() => {
      mergeUrlParams.mockClear();
      historyPushState.mockClear();
      wrapper.setProps({ query: newQuery });
    });

    it('updates the URL with the new query', () => expectUrlSync(newQuery));
  });
});

import testAction from 'helpers/vuex_action_helper';
import { useLocalStorageSpy } from 'helpers/local_storage_helper';
import MockAdapter from 'axios-mock-adapter';
import waitForPromises from 'helpers/wait_for_promises';
import actions from '~/whats_new/store/actions';
import * as types from '~/whats_new/store/mutation_types';
import axios from '~/lib/utils/axios_utils';

describe('whats new actions', () => {
  describe('openDrawer', () => {
    useLocalStorageSpy();

    it('should commit openDrawer', () => {
      testAction(actions.openDrawer, 'storage-key', {}, [{ type: types.OPEN_DRAWER }]);

      expect(window.localStorage.setItem).toHaveBeenCalledWith('storage-key', 'false');
    });
  });

  describe('closeDrawer', () => {
    it('should commit closeDrawer', () => {
      testAction(actions.closeDrawer, {}, {}, [{ type: types.CLOSE_DRAWER }]);
    });
  });

  describe('fetchItems', () => {
    let axiosMock;

    beforeEach(async () => {
      axiosMock = new MockAdapter(axios);
      axiosMock
        .onGet('/-/whats_new')
        .replyOnce(200, [{ title: 'Whats New Drawer', url: 'www.url.com' }], {
          'x-next-page': '2',
          'x-page': '1',
        });

      await waitForPromises();
    });

    afterEach(() => {
      axiosMock.restore();
    });

    it('should commit setFeatures and setPagination', () => {
      testAction(actions.fetchItems, {}, {}, [
        { type: types.SET_FEATURES, payload: [{ title: 'Whats New Drawer', url: 'www.url.com' }] },
        { type: types.SET_PAGINATION, payload: { currentPage: 1, nextPage: 2 } },
      ]);
    });
  });

  describe('bottomReached', () => {
    it('when nextPage exists dispatches fetchItems', () => {
      testAction(
        actions.bottomReached,
        {},
        { pageInfo: { nextPage: 840 } },
        [],
        [{ payload: 840, type: 'fetchItems' }],
      );
    });

    it('when nextPage does not exist it does not dispatch fetchItems', () => {
      testAction(actions.bottomReached, {}, { pageInfo: { nextPage: null } }, [], []);
    });
  });
});

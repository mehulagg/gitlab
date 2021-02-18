import { shallowMount } from '@vue/test-utils';
import AssigneesRealtime from '~/sidebar/components/assignees/assignees_realtime.vue';
import SidebarMediator from '~/sidebar/sidebar_mediator';
import Mock from './mock_data';

describe('Assignees Realtime', () => {
  let wrapper;
  let mediator;

  const createComponent = () => {
    wrapper = shallowMount(AssigneesRealtime, {
      propsData: {
        issuableType: 'issue',
        issuableId: 1,
        mediator,
      },
    });
  };

  beforeEach(() => {
    mediator = new SidebarMediator(Mock.mediator);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    SidebarMediator.singleton = null;
  });

  describe('computed', () => {
    describe('issuableClass', () => {
      it('returns the correct issuable class', () => {
        createComponent();

        expect(wrapper.vm.issuableClass).toBe('Issue');
      });
    });
  });

  describe('when handleFetchResult is called from smart subscription', () => {
    it('sets assignees to the store', () => {
      const data = {
        issuableAssigneesUpdated: [{ id: 'gid://gitlab/User/123', avatarUrl: 'url' }],
      };
      const expected = [{ id: 123, avatar_url: 'url', avatarUrl: 'url' }];
      createComponent();

      wrapper.vm.handleFetchResult({ data });

      expect(mediator.store.assignees).toEqual(expected);
    });
  });
});

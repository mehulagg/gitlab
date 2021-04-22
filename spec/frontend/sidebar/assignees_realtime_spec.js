import { shallowMount } from '@vue/test-utils';
import AssigneesRealtime from '~/sidebar/components/assignees/assignees_realtime.vue';
import SidebarMediator from '~/sidebar/sidebar_mediator';
import Mock from './mock_data';

describe('Assignees Realtime', () => {
  let wrapper;
  let mediator;

  const createComponent = (issuableType = 'issue', issuableId = 1) => {
    wrapper = shallowMount(AssigneesRealtime, {
      propsData: {
        issuableType,
        issuableId,
        queryVariables: {
          issuableIid: '1',
          projectPath: 'path/to/project',
        },
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
});

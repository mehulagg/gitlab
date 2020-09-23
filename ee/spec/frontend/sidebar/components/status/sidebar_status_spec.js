import { shallowMount } from '@vue/test-utils';
import SidebarStatus from 'ee/sidebar/components/status/sidebar_status.vue';
import Status from 'ee/sidebar/components/status/status.vue';

describe('SidebarStatus', () => {
  let mediator;
  let wrapper;
  let handleDropdownClickMock;

  const createMediator = states => {
    mediator = {
      store: {
        isFetching: {
          status: true,
        },
        status: '',
        ...states,
      },
    };
  };

  const createWrapper = (mockStore = {}) => {
    wrapper = shallowMount(SidebarStatus, {
      propsData: {
        mediator,
      },
      methods: {
        handleDropdownClick: handleDropdownClickMock,
      },
      mocks: {
        $store: mockStore,
      },
    });
  };

  beforeEach(() => {
    handleDropdownClickMock = jest.fn();
    createMediator();
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('computed', () => {
    describe.each`
      noteableState | isOpen
      ${'opened'}   | ${true}
      ${'reopened'} | ${true}
      ${'closed'}   | ${false}
    `('isOpen', ({ noteableState, isOpen }) => {
      beforeEach(() => {
        const mockStore = {
          getters: {
            getNoteableData: {
              state: noteableState,
            },
          },
        };
        createMediator({ editable: true });
        createWrapper(mockStore);
      });

      it(`returns ${isOpen} when issue is ${noteableState}`, () => {
        expect(wrapper.vm.isOpen).toBe(isOpen);
      });
    });
  });

  describe('Status child component', () => {
    beforeEach(() => {});

    it('renders Status component', () => {
      expect(wrapper.find(Status).exists()).toBe(true);
    });

    it('calls handleFormSubmission when receiving an onDropdownClick event from Status component', () => {
      wrapper.find(Status).vm.$emit('onDropdownClick', 'onTrack');

      expect(handleDropdownClickMock).toHaveBeenCalledWith('onTrack');
    });
  });

  it('calls handleFormSubmission when receiving an onFormSubmit event from Status component', () => {
    wrapper.find(Status).vm.$emit('onDropdownClick', 'onTrack');

    expect(handleDropdownClickMock).toHaveBeenCalledWith('onTrack');
  });
});

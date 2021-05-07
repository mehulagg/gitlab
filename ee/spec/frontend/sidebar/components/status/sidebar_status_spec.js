import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import Vuex from 'vuex';
import SidebarStatus from 'ee/sidebar/components/status/sidebar_status.vue';
import Status from 'ee/sidebar/components/status/status.vue';

Vue.use(Vuex);

describe('SidebarStatus', () => {
  let mediator;
  let wrapper;

  const createMediator = (states) => {
    mediator = {
      updateStatus: jest.fn().mockResolvedValue(),
      store: {
        isFetching: {
          status: true,
        },
        status: '',
        ...states,
      },
    };
  };

  const createWrapper = ({ noteableState } = {}) => {
    const store = new Vuex.Store({
      getters: {
        getNoteableData: () => ({ state: noteableState }),
      },
    });
    wrapper = shallowMount(SidebarStatus, {
      propsData: {
        mediator,
      },
      store,
    });
  };

  beforeEach(() => {
    createMediator();
    createWrapper({
      getters: {
        getNoteableData: {},
      },
    });
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
        createMediator({ editable: true });
        createWrapper({ noteableState });
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

    it('calls mediator status update when receiving an onDropdownClick event from Status component', () => {
      wrapper.find(Status).vm.$emit('onDropdownClick', 'onTrack');

      expect(mediator.updateStatus).toHaveBeenCalledWith('onTrack');
    });
  });
});

import { shallowMount } from '@vue/test-utils';
import { ApolloMutation, ApolloQuery } from 'vue-apollo';
import SidebarStatus from 'ee/sidebar/components/status/sidebar_status.vue';
import Status from 'ee/sidebar/components/status/status.vue';
import { healthStatusQueries } from 'ee/sidebar/constants';

const mutate = jest.fn().mockResolvedValue();

describe('SidebarStatus', () => {
  let wrapper;

  const createWrapper = ({
    issuableType = 'issue',
    state = 'opened',
    healthStatus = 'onTrack',
    loading = false,
  } = {}) => {
    const $apollo = {
      queries: {
        issuableData: {
          loading,
        },
      },
      mutate,
    };
    wrapper = shallowMount(SidebarStatus, {
      propsData: {
        issuableType,
        iid: '1',
        fullPath: 'foo/bar',
        canUpdate: true,
      },
      data() {
        return {
          issuableData: {
            state,
            healthStatus,
          },
        };
      },
      sync: false,
      mocks: { $apollo },
      stubs: {
        ApolloMutation,
        ApolloQuery,
      },
    });
  };

  beforeEach(() => {
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('computed', () => {
    describe.each`
      state         | isOpen
      ${'opened'}   | ${true}
      ${'reopened'} | ${true}
      ${'closed'}   | ${false}
    `('isOpen', ({ state, isOpen }) => {
      beforeEach(() => {
        createWrapper({ state });
      });

      it(`returns ${isOpen} when issue is ${state}`, () => {
        expect(wrapper.vm.isOpen).toBe(isOpen);
      });
    });
  });

  describe('Status child component', () => {
    beforeEach(() => {});

    it('renders Status component', () => {
      expect(wrapper.find(Status).exists()).toBe(true);
    });

    it('calls apollo mutate when receiving an onDropdownClick event from Status component', () => {
      wrapper.find(Status).vm.$emit('onDropdownClick', 'onTrack');

      const mutationVariables = {
        mutation: healthStatusQueries.issue.mutation,
        variables: {
          projectPath: 'foo/bar',
          iid: '1',
          healthStatus: 'onTrack',
        },
      };

      expect(mutate).toHaveBeenCalledWith(mutationVariables);
    });
  });
});

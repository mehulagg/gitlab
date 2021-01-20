import { GlDropdownItem, GlSearchBoxByType, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, mount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import IterationDropdown from 'ee/sidebar/components/iteration_dropdown.vue';
import { iterationSelectTextMap } from 'ee/sidebar/constants';
import groupIterationsQuery from 'ee/sidebar/queries/group_iterations.query.graphql';
import waitForPromises from 'helpers/wait_for_promises';

const localVue = createLocalVue();

localVue.use(VueApollo);

describe('IterationDropdown', () => {
  let wrapper;
  let fakeApollo;
  let groupIterationsSpy;
  const iterations = [
    {
      username: 'root',
      name: 'root',
      webUrl: '',
      avatarUrl: '',
      id: 'id',
      title: 'title',
      state: '',
    },
  ];

  const createComponent = ({ data = {}, props = {}, loading = false }) => {
    wrapper = shallowMount(IterationDropdown, {
      data() {
        return data;
      },
      propsData: {
        ...props,
        fullPath: '',
      },
      mocks: {
        $options: {
          noIterationItem: [],
        },
        $apollo: {
          loading,
        },
      },
      stubs: {
        GlSearchBoxByType,
      },
    });
  };

  const createComponentWithApollo = (data = {}, props = {}) => {
    fakeApollo = createMockApollo([[groupIterationsQuery, groupIterationsSpy]]);
    wrapper = mount(IterationDropdown, {
      localVue,
      apolloProvider: fakeApollo,
      data() {
        return { ...data };
      },
      propsData: {
        ...props,
        fullPath: '',
        issueIid: '',
      },
      mocks: {
        $options: {
          noIterationItem: [],
        },
      },
      stubs: {
        GlSearchBoxByType,
      },
    });
  };

  afterEach(() => {
    jest.restoreAllMocks();
    wrapper.destroy();
    wrapper = null;
  });

  describe.each`
    loading  | exists
    ${true}  | ${true}
    ${false} | ${false}
  `('when apollo loading is $loading', ({ loading, exists }) => {
    beforeEach(() => {
      createComponent({
        loading,
      });
    });

    it(`GlLoadingIcon exists is ${exists}`, () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(exists);
    });
  });

  describe.each`
    shouldFetch | called
    ${true}     | ${true}
    ${false}    | ${false}
  `('when shouldFetch query is $shouldFetch', ({ shouldFetch, called }) => {
    beforeEach(() => {
      groupIterationsSpy = jest.fn().mockResolvedValue({
        data: {
          group: {
            iterations: {
              nodes: iterations,
            },
          },
        },
      });

      createComponentWithApollo({
        shouldFetch,
      });
    });

    it(`groupIterations query called ${called}`, () => {
      const times = called ? 1 : 0;

      jest.advanceTimersByTime(250);

      expect(groupIterationsSpy).toHaveBeenCalledTimes(times);
    });
  });

  describe('on mount', () => {
    describe('when bootstrap dropdown event is emitted', () => {
      it('changes shouldFetch to be true', async () => {
        createComponent({});

        expect(wrapper.vm.shouldFetch).toBe(false);

        wrapper.vm.$root.$emit('bv::dropdown::shown');

        expect(wrapper.vm.shouldFetch).toBe(true);
      });
    });
  });

  describe('GlDropdownItem with the right title and id', () => {
    const id = 'id';
    const title = 'title';

    beforeEach(() => {
      createComponent({
        data: { iterations: [{ id, title }], currentIteration: { id, title } },
      });
    });

    it('renders title $title', () => {
      expect(
        wrapper
          .findAll(GlDropdownItem)
          .filter((w) => w.text() === title)
          .at(0)
          .text(),
      ).toBe(title);
    });

    it('checks the correct dropdown item', () => {
      expect(
        wrapper
          .findAll(GlDropdownItem)
          .filter((w) => w.props('isChecked') === true)
          .at(0)
          .text(),
      ).toBe(title);
    });
  });

  describe('when clicking on dropdown item', () => {
    beforeEach(() => {
      groupIterationsSpy = jest.fn().mockResolvedValue({
        data: {
          group: {
            iterations: {
              nodes: iterations,
            },
          },
        },
      });
    });

    describe('when currentIteration id is equal to iteration id', () => {
      it('does not emit event', async () => {
        createComponentWithApollo({
          shouldFetch: true,
          currentIteration: { id: 'id', title: 'title' },
        });

        jest.advanceTimersByTime(250);
        await waitForPromises();

        wrapper
          .findAll(GlDropdownItem)
          .filter((w) => w.text() === 'title')
          .at(0)
          .vm.$emit('click');

        expect(wrapper.emitted('onIterationSelect')).toBeUndefined();
      });
    });

    describe('when currentIteration is not equal to iteration id', () => {
      it('emits event', async () => {
        createComponentWithApollo({
          shouldFetch: true,
          currentIteration: { id: '', title: 'title' },
        });

        jest.advanceTimersByTime(250);
        await waitForPromises();

        wrapper
          .findAll(GlDropdownItem)
          .filter((w) => w.text() === 'title')
          .at(0)
          .vm.$emit('click');

        expect(wrapper.emitted('onIterationSelect')).toHaveLength(1);
      });
    });
  });

  describe('when a user is searching', () => {
    beforeEach(() => {
      createComponent({});
    });

    it('sets the search term', async () => {
      wrapper.find(GlSearchBoxByType).vm.$emit('input', 'testing');

      await wrapper.vm.$nextTick();

      expect(wrapper.vm.searchTerm).toBe('testing');
    });
  });
});

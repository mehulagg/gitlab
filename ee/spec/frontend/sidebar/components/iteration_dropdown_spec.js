import { GlDropdownItem, GlLoadingIcon, GlDropdown, GlSearchBoxByType } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import IterationDropdown from 'ee/sidebar/components/iteration_dropdown.vue';
import groupIterationsQuery from 'ee/sidebar/queries/group_iterations.query.graphql';
import { iterationSelectTextMap } from 'ee/sidebar/constants';

const localVue = createLocalVue();

localVue.use(VueApollo);

const TEST_SEARCH = 'search';
const TEST_FULL_PATH = 'gitlab-test/test';
const TEST_ITERATIONS = [
  {
    id: '1',
    title: 'Test Title',
    webUrl: '',
    state: '',
  },
  {
    id: '2',
    title: 'Another Test Title',
    webUrl: '',
    state: '',
  },
];

describe('IterationDropdown', () => {
  let wrapper;
  let fakeApollo;
  let groupIterationsSpy;

  beforeEach(() => {
    groupIterationsSpy = jest.fn().mockResolvedValue({
      data: {
        group: {
          iterations: {
            nodes: TEST_ITERATIONS,
          },
        },
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const waitForDebounce = async () => {
    await wrapper.vm.$nextTick();
    jest.runOnlyPendingTimers();
  };
  const findDropdownItems = () => wrapper.findAll(GlDropdownItem);
  const findDropdownItemWithText = (text) =>
    findDropdownItems().wrappers.find((x) => x.text() === text);
  const findDropdownItemsData = () =>
    findDropdownItems().wrappers.map((x) => ({
      isCheckItem: x.props('isCheckItem'),
      isChecked: x.props('isChecked'),
      text: x.text(),
    }));
  const selectDropdownItemAndWait = async (text) => {
    const item = findDropdownItemWithText(text);

    item.vm.$emit('click');

    await wrapper.vm.$nextTick();
  };
  const findDropdown = () => wrapper.find(GlDropdown);
  const showDropdownAndWait = async () => {
    findDropdown().vm.$emit('show');

    await waitForDebounce();
  };
  const isLoading = () => wrapper.find(GlLoadingIcon).exists();

  const createComponent = ({ mountFn = shallowMount } = {}) => {
    fakeApollo = createMockApollo([[groupIterationsQuery, groupIterationsSpy]]);

    wrapper = mountFn(IterationDropdown, {
      localVue,
      apolloProvider: fakeApollo,
      propsData: {
        fullPath: TEST_FULL_PATH,
      },
    });
  };

  describe('default', () => {
    beforeEach(() => {
      createComponent();
    });

    it('does not show loading', () => {
      expect(isLoading()).toBe(false);
    });

    it('shows gl-dropdown', () => {
      expect(wrapper.find(GlDropdown).exists()).toBe(true);
      expect(wrapper.find(GlDropdown).element).toMatchSnapshot();
    });
  });

  describe('when dropdown opens and query is loading', () => {
    beforeEach(async () => {
      // return promise that doesn't resolve to force loading state
      groupIterationsSpy.mockReturnValue(new Promise(() => {}));

      createComponent();

      await showDropdownAndWait();
    });

    it('shows loading', () => {
      expect(isLoading()).toBe(true);
    });

    it('calls groupIterations query', () => {
      expect(groupIterationsSpy).toHaveBeenCalledTimes(1);
      expect(groupIterationsSpy).toHaveBeenCalledWith({
        fullPath: TEST_FULL_PATH,
        state: 'opened',
        title: '',
      });
    });
  });

  describe('when dropdown opens and query responds', () => {
    beforeEach(async () => {
      createComponent();

      await showDropdownAndWait();
    });

    it('does not show loading', () => {
      expect(isLoading()).toBe(false);
    });

    it('shows dropdown items', () => {
      const result = iterationSelectTextMap.noIterationItem.concat(TEST_ITERATIONS);

      expect(findDropdownItemsData()).toEqual(
        result.map((x) => ({
          isCheckItem: true,
          isChecked: false,
          text: x.title,
        })),
      );
    });

    it('does not re-query if opened again', async () => {
      groupIterationsSpy.mockClear();
      await showDropdownAndWait();

      expect(groupIterationsSpy).not.toHaveBeenCalled();
    });

    describe.each([0, 1, 2])('when item %s is selected', (index) => {
      const allIterations = iterationSelectTextMap.noIterationItem.concat(TEST_ITERATIONS);
      const selected = allIterations[index];
      const asNotChecked = ({ title }) => ({ isCheckItem: true, isChecked: false, text: title });

      beforeEach(async () => {
        await selectDropdownItemAndWait(selected.title);
      });

      it('shows item as checked', () => {
        const prevSelected = allIterations.slice(0, index);
        const afterSelected = allIterations.slice(index + 1);

        expect(findDropdownItemsData()).toEqual([
          ...prevSelected.map(asNotChecked),
          {
            isCheckItem: true,
            isChecked: true,
            text: selected.title,
          },
          ...afterSelected.map(asNotChecked),
        ]);
      });

      it('emits event', () => {
        expect(wrapper.emitted('onIterationSelect')).toEqual([[selected]]);
      });

      describe('when item is clicked again', () => {
        beforeEach(async () => {
          await selectDropdownItemAndWait(selected.title);
        });

        it('shows item as unchecked', () => {
          expect(findDropdownItemsData()).toEqual(allIterations.map(asNotChecked));
        });

        it('emits event', () => {
          expect(wrapper.emitted('onIterationSelect').length).toBe(2);
          expect(wrapper.emitted('onIterationSelect')[1]).toEqual([null]);
        });
      });
    });
  });

  describe('when dropdown opens and search is set', () => {
    beforeEach(async () => {
      createComponent();

      await showDropdownAndWait();

      groupIterationsSpy.mockClear();

      wrapper.find(GlSearchBoxByType).vm.$emit('input', TEST_SEARCH);

      await waitForDebounce();
    });

    it('adds the search to the query', () => {
      expect(groupIterationsSpy).toHaveBeenCalledWith({
        fullPath: TEST_FULL_PATH,
        state: 'opened',
        title: `"${TEST_SEARCH}"`,
      });
    });
  });
});

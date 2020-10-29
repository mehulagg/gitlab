import StandardFilter from 'ee/security_dashboard/components/filters/standard_filter.vue';
import FilterBody from 'ee/security_dashboard/components/filters/filter_body.vue';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueRouter from 'vue-router';

const localVue = createLocalVue();
localVue.use(VueRouter);
const router = new VueRouter();

const generateOptions = length => {
  return Array.from({ length }).map((_, i) => ({
    name: `Option ${i}`,
    id: `option-${i}`,
    index: i,
  }));
};

const filter = Object.freeze({ id: 'filter', name: 'filter', options: generateOptions(12) });
const optionAt = index => filter.options[index];
const optionsAt = (...indexes) => filter.options.filter((_, i) => indexes.includes(i));
const allOption = { id: 'allOptionId' };

describe('Standard Filter component', () => {
  let wrapper;

  const createWrapper = (filterOptions, showSearchBox) => {
    wrapper = shallowMount(StandardFilter, {
      localVue,
      router,
      propsData: { filter: { ...filter, ...filterOptions }, showSearchBox },
    });
  };

  const dropdownItems = () => wrapper.findAll('[data-testid="option"]');
  const dropdownItemAt = index => dropdownItems().at(index);
  const allOptionItem = () => wrapper.find('[data-testid="allOption"]');
  const isChecked = item => item.props('isChecked');
  const filterQuery = () => wrapper.vm.$route.query[filter.id];
  const clickAllOptionItem = () => allOptionItem().vm.$emit('click');

  const clickItemAt = async index => {
    dropdownItemAt(index).vm.$emit('click');
    await wrapper.vm.$nextTick();
  };

  const expectSelectedItems = indexes => {
    const checkedIndexes = dropdownItems().wrappers.map(item => isChecked(item));
    const expectedIndexes = Array.from({ length: checkedIndexes.length }).map((_, index) =>
      indexes.includes(index),
    );

    expect(checkedIndexes).toEqual(expectedIndexes);
  };

  const expectAllOptionSelected = () => {
    expect(isChecked(allOptionItem())).toBe(true);
    const checkedIndexes = dropdownItems().wrappers.map(item => isChecked(item));
    const expectedIndexes = new Array(checkedIndexes.length).fill(false);

    expect(checkedIndexes).toEqual(expectedIndexes);
  };

  afterEach(() => {
    // Clear out the querystring if one exists. It persists between tests.
    if (filterQuery()?.length) {
      wrapper.vm.$router.push('/');
    }
    wrapper.destroy();
  });

  describe('filter options', () => {
    it('shows the filter options', () => {
      createWrapper();

      expect(dropdownItems()).toHaveLength(filter.options.length);
    });

    it.each`
      phrase             | allItem
      ${'shows'}         | ${allOption}
      ${'does not show'} | ${undefined}
    `(`$phrase the All option if filter.allOption is $allOption`, ({ allItem }) => {
      createWrapper({ allOption: allItem });

      expect(allOptionItem().exists()).toBe(Boolean(allItem));
    });

    it.each`
      allItem      | defaultOptions
      ${allOption} | ${optionsAt(5, 2)}
      ${allOption} | ${[]}
      ${allOption} | ${undefined}
      ${undefined} | ${optionsAt(2, 4)}
      ${undefined} | ${[]}
      ${undefined} | ${undefined}
    `(
      'should pre-select the correct option(s) when allOption is $allOption and defaultOptions is $defaultOptions',
      ({ allItem, defaultOptions }) => {
        createWrapper({ allItem, defaultOptions });

        if (allOptionItem().exists()) {
          // Check that the All option is checked only if there aren't default options.
          expect(isChecked(allOptionItem())).toBe(!defaultOptions?.length);
        }

        // Check if the default options are checked.
        expectSelectedItems(defaultOptions?.map(x => x.index) || []);
      },
    );
  });

  describe('search box', () => {
    it.each`
      phrase             | showSearchBox
      ${'shows'}         | ${true}
      ${'does not show'} | ${false}
    `('$phrase search box if showSearchBox is $showSearchBox', ({ showSearchBox }) => {
      createWrapper({}, showSearchBox);

      expect(wrapper.find(FilterBody).props('showSearchBox')).toBe(showSearchBox);
    });

    it('filters options when something is typed in the search box', async () => {
      const expectedItems = filter.options.map(x => x.name).filter(x => x.includes('1'));
      createWrapper({}, true);
      wrapper.find(FilterBody).vm.$emit('input', '1');
      await wrapper.vm.$nextTick();

      expect(dropdownItems()).toHaveLength(3);
      expect(dropdownItems().wrappers.map(x => x.props('text'))).toEqual(expectedItems);
    });
  });

  describe('selecting options', () => {
    beforeEach(() => {
      createWrapper({ allOption: {}, defaultOptions: optionsAt(1, 2, 3) });
    });

    it('de-selects every option and selects the all option when all option is clicked', async () => {
      const clickAndCheck = async () => {
        clickAllOptionItem();
        await wrapper.vm.$nextTick();

        expectAllOptionSelected();
      };

      // Click the all option 3 times. We're checking that it doesn't toggle.
      await clickAndCheck();
      await clickAndCheck();
      await clickAndCheck();
    });

    it(`toggles an option's selection when it it repeatedly clicked`, async () => {
      const item = dropdownItemAt(5);
      let checkedState = isChecked(item);

      const clickAndCheck = async () => {
        item.vm.$emit('click');
        await wrapper.vm.$nextTick();

        expect(isChecked(allOptionItem())).toBe(false);
        expect(isChecked(item)).toBe(!checkedState);
        checkedState = isChecked(item);
      };

      // Click the option 3 times. We're checking that toggles.
      await clickAndCheck();
      await clickAndCheck();
      await clickAndCheck();
    });

    it('multi-selects options when multiple items are clicked', async () => {
      await [5, 6, 7].forEach(async index => {
        clickItemAt(index);
        await wrapper.vm.$nextTick();
      });

      expectSelectedItems([1, 2, 3, 5, 6, 7]);
    });

    it('automatically selects the all option when last selected option is clicked to unselect it', async () => {
      [1, 2, 3].forEach(clickItemAt);
      await wrapper.vm.$nextTick();

      expectAllOptionSelected();
    });

    it('emits filter-changed event when an option is clicked', async () => {
      clickItemAt(4);
      const expectedIds = optionsAt(1, 2, 3, 4).map(x => x.id);
      await wrapper.vm.$nextTick();

      expect(wrapper.emitted('filter-changed')).toHaveLength(1);
      expect(wrapper.emitted('filter-changed')[0][0]).toEqual({ [filter.id]: expectedIds });
    });
  });

  describe('querystring stuff', () => {
    const updateRouteQuery = (indexes = []) => {
      // window.history.back() won't change the location nor fire the popstate event, so we need
      // to fake it by doing it manually.
      router.replace({ query: { [filter.id]: optionsAt(...indexes).map(x => x.id) } });
      window.dispatchEvent(new Event('popstate'));
    };

    const updateRouteQueryRaw = ids => {
      // window.history.back() won't change the location nor fire the popstate event, so we need
      // to fake it by doing it manually.
      router.replace({ query: { [filter.id]: ids } });
      window.dispatchEvent(new Event('popstate'));
    };

    it('should update the querystring when options are clicked', async () => {
      createWrapper();
      const clickedIds = [];

      [1, 3, 5].forEach(index => {
        clickItemAt(index);
        clickedIds.push(optionAt(index).id);
        expect(filterQuery()).toEqual(clickedIds);
      });
    });

    it('should set the querystring properly when the All option is clicked', async () => {
      createWrapper({ allOption });
      [1, 2, 3, 4].forEach(clickItemAt);
      await wrapper.vm.$nextTick();

      expect(filterQuery()).toHaveLength(4);

      clickAllOptionItem();
      await wrapper.vm.$nextTick();

      expect(filterQuery()).toEqual([allOption.id]);
    });

    it('changing querystring to something existing should select those options', async () => {
      createWrapper();
      const indexes = [3, 5, 7];
      updateRouteQuery(indexes);
      await wrapper.vm.$nextTick();

      expectSelectedItems(indexes);
    });

    it('changing querystring to blank should select default options', async () => {
      createWrapper({ defaultOptions: optionsAt(2, 5, 8) });
      clickItemAt(3);
      await wrapper.vm.$nextTick();

      expectSelectedItems([2, 3, 5, 8]);

      updateRouteQuery();
      await wrapper.vm.$nextTick();

      expectSelectedItems([2, 5, 8]);
    });

    it('changing querystring to blank should select All option if no default options', async () => {
      createWrapper({ allOption: {} });
      clickItemAt(3);
      await wrapper.vm.$nextTick();

      expectSelectedItems([3]);

      updateRouteQuery();
      await wrapper.vm.$nextTick();

      expectAllOptionSelected();
    });

    it('changing querystring to all option ID should select all option', async () => {
      createWrapper({ allOption, defaultOptions: optionsAt(2, 4, 8) });

      expectSelectedItems([2, 4, 8]);

      updateRouteQueryRaw([allOption.id]);
      await wrapper.vm.$nextTick();

      expectAllOptionSelected();
    });

    it('changing querystring to something that has valid and invalid items should only select the valid items', async () => {
      createWrapper();
      const ids = optionsAt(3, 7, 9)
        .map(x => x.id)
        .concat(['some', 'invalid', 'ids']);
      updateRouteQueryRaw(ids);
      await wrapper.vm.$nextTick();

      expectSelectedItems([3, 7, 9]);
    });

    it('changing querystring to something that only has invalid items should select the default options', async () => {
      createWrapper({ defaultOptions: optionsAt(1, 3, 4) });
      await clickItemAt(8);

      expectSelectedItems([1, 3, 4, 8]);

      updateRouteQueryRaw(['some', 'invalid', 'ids']);
      await wrapper.vm.$nextTick();
      expectSelectedItems([1, 3, 4]);
    });

    it('changing querystring to something that only has invalid items should select the All option', async () => {
      createWrapper({ allOption: {} });
      clickItemAt(8);
      await wrapper.vm.$nextTick();

      expectSelectedItems([8]);

      updateRouteQueryRaw(['some', 'invalid', 'ids']);
      await wrapper.vm.$nextTick();
      expectAllOptionSelected();
    });

    it('changing querystring to something that has all and other options will only select the All option', async () => {
      createWrapper({ allOption });
      updateRouteQueryRaw([allOption.id, optionAt(1).id, optionAt(2).id]);
      await wrapper.vm.$nextTick();

      expectAllOptionSelected();
    });

    it('selects correct items from querystring on load', () => {
      updateRouteQuery([1, 3, 5, 7]);
      createWrapper();

      expectSelectedItems([1, 3, 5, 7]);
    });

    it('selects correct items if querystring has valid and invalid items', async () => {
      const ids = optionsAt(2, 4, 6)
        .map(x => x.id)
        .concat(['some', 'invalid', 'ids']);
      updateRouteQueryRaw(ids);
      createWrapper();

      expectSelectedItems([2, 4, 6]);
    });

    it('selects default options if querystring only has invalid items', async () => {
      updateRouteQueryRaw(['some', 'invalid', 'ids']);
      createWrapper({ defaultOptions: optionsAt(4, 5, 8) });

      expectSelectedItems([4, 5, 8]);
    });

    it('selects All option if querystring only has invalid items', async () => {
      updateRouteQueryRaw(['some', 'invalid', 'ids']);
      createWrapper({ allOption });

      expectAllOptionSelected();
    });

    it('updating querystring for one filter does not touch querystring for another filter', async () => {
      createWrapper();

      const ids = optionsAt(1, 2, 3).map(x => x.id);
      const other = ['6', '7', '8'];
      const query = { [filter.id]: ids, other };
      router.replace({ query });
      window.dispatchEvent(new Event('popstate'));
      await wrapper.vm.$nextTick();

      expectSelectedItems([1, 2, 3]);
      expect(wrapper.vm.$route.query.other).toEqual(other);
    });
  });
});

import StandardFilter from 'ee/security_dashboard/components/filters/standard_filter.vue';
import FilterBody from 'ee/security_dashboard/components/filters/filter_body.vue';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueRouter from 'vue-router';

const localVue = createLocalVue();
localVue.use(VueRouter);
const router = new VueRouter();

const generateOption = index => ({
  name: `Option ${index}`,
  id: `option-${index}`,
});

const generateOptions = length => {
  return Array.from({ length }).map((_, i) => generateOption(i));
};

const filter = Object.freeze({ name: 'filter', options: generateOptions(12) });
const optionAt = i => filter.options[i];

describe('Standard Filter component', () => {
  let wrapper;

  const createWrapper = (filterInstance, showSearchBox) => {
    wrapper = shallowMount(StandardFilter, {
      localVue,
      router,
      propsData: { filter: filterInstance, showSearchBox },
    });
  };

  const dropdownItems = () => wrapper.findAll('[data-testid="option"]');
  const dropdownItemAt = index => dropdownItems().at(index);
  const allOptionItem = () => wrapper.find('[data-testid="allOption"]');
  const isChecked = item => item.props('isChecked');
  const filterQuery = () => wrapper.vm.$route.query[filter.id];

  afterEach(() => {
    // If the test changed the querystring, clear it out. The querystring persists between tests.
    if (Object.keys(wrapper.vm.$route.query).length) {
      wrapper.vm.$router.push({ query: undefined });
    }
    wrapper.destroy();
  });

  describe('filter options', () => {
    it('should show the filter options', () => {
      createWrapper(filter);

      expect(dropdownItems()).toHaveLength(filter.options.length);
    });

    it.each`
      phrase          | allOption
      ${'should'}     | ${{}}
      ${'should not'} | ${undefined}
    `(`$phrase show the 'All' option if filter.allOption is $allOption`, ({ allOption }) => {
      createWrapper({ ...filter, allOption });

      expect(allOptionItem().exists()).toBe(Boolean(allOption));
    });

    it.each`
      allOption    | defaultOptions
      ${{}}        | ${[optionAt(5), optionAt(2)]}
      ${{}}        | ${[]}
      ${{}}        | ${undefined}
      ${undefined} | ${[optionAt(2), optionAt(4)]}
      ${undefined} | ${[]}
      ${undefined} | ${undefined}
    `(
      'should pre-select the correct option(s) when allOption is $allOption and defaultOptions is $defaultOptions',
      ({ allOption, defaultOptions }) => {
        createWrapper({ ...filter, allOption, defaultOptions });

        if (allOptionItem().exists()) {
          expect(isChecked(allOptionItem())).toBe(!defaultOptions?.length);
        }
        // Check if the default options are checked.
        dropdownItems().wrappers.forEach((item, i) => {
          expect(isChecked(item)).toBe(Boolean(defaultOptions?.includes(optionAt(i))));
        });
      },
    );
  });

  describe('search box', () => {
    it.each`
      phrase          | showSearchBox
      ${'should'}     | ${true}
      ${'should not'} | ${false}
    `('$phrase show search box if showSearchBox is $showSearchBox', ({ showSearchBox }) => {
      createWrapper(filter, showSearchBox);

      expect(wrapper.find(FilterBody).props('showSearchBox')).toBe(showSearchBox);
    });

    it('typing something in the search box should filter options', async () => {
      const expectedItems = filter.options.filter(x => x.name.includes('1')).map(x => x.name);
      createWrapper(filter, true);
      wrapper.find(FilterBody).vm.$emit('input', '1');
      await wrapper.vm.$nextTick();

      expect(dropdownItems()).toHaveLength(3);
      expect(dropdownItems().wrappers.map(x => x.props('text'))).toEqual(expectedItems);
    });
  });

  describe('selecting options', () => {
    beforeEach(() => {
      createWrapper({
        ...filter,
        allOption: {},
        defaultOptions: [optionAt(1), optionAt(2), optionAt(3)],
      });
    });

    it('should deselect all options and select the all option even when clicked repeatedly', async () => {
      const clickAndCheck = async () => {
        allOptionItem().vm.$emit('click');
        await wrapper.vm.$nextTick();

        expect(isChecked(allOptionItem())).toBe(true);
        dropdownItems().wrappers.forEach(item => expect(isChecked(item)).toBe(false));
      };

      // Click the all option 3 times. We're checking that it doesn't toggle.
      await clickAndCheck();
      await clickAndCheck();
      await clickAndCheck();
    });

    it(`should toggle an option's selection when it it repeatedly clicked`, async () => {
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

    it('should multi-select options when multiple items are clicked', async () => {
      const indexes = [5, 6, 7];

      await indexes.forEach(async index => {
        dropdownItemAt(index).vm.$emit('click');
        await wrapper.vm.$nextTick();
      });

      indexes.forEach(index => {
        expect(isChecked(dropdownItemAt(index))).toBe(true);
      });
    });
  });

  describe('querystring stuff', () => {
    it('should update the querystring when options are clicked', async () => {
      createWrapper(filter);
      const clickedIds = [];

      [1, 3, 5].forEach(async index => {
        dropdownItemAt(index).vm.$emit('click');
        clickedIds.push(optionAt(index).id);
        await wrapper.vm.$nextTick();

        expect(filterQuery()).toEqual(clickedIds);
      });
    });

    it('clicking on the all option should update the querystring with all', async () => {
      const allOption = { id: 'allOptionId' };
      createWrapper({ ...filter, allOption });
      [1, 2, 3, 4].forEach(index => dropdownItemAt(index).vm.$emit('click'));
      await wrapper.vm.$nextTick();

      expect(filterQuery()).toHaveLength(4);

      allOptionItem().vm.$emit('click');
      await wrapper.vm.$nextTick();

      expect(filterQuery()).toEqual([allOption.id]);
    });

    it('clicking back/forward navigation should sync the selected options, but not update the querystring', () => {});
    it('if querystring starts with query param, it should sync the selected options', () => {});
    it('if querystring starts with query param but it has valid and invalid items, it should sync only the valid options', () => {});
    it('if querystring starts with query param but it only has invalid items, it should not select anything and use the default options', () => {});
    it('updating querystring for one filter does not touch querystring for another filter', () => {});
  });
});

import { shallowMount } from '@vue/test-utils';
import FilterBody from 'ee/security_dashboard/components/shared/filters/filter_body.vue';
import ProjectFilterOld from 'ee/security_dashboard/components/shared/filters/project_filter_old.vue';

const generateOptions = (length) =>
  Array.from({ length }).map((_, i) => ({ name: `Option ${i}`, id: `option-${i}`, index: i }));

const filter = {
  id: 'filter',
  name: 'filter',
  options: generateOptions(12),
  allOption: { id: 'allOptionId' },
  defaultOptions: [],
};

describe('Standard Filter component', () => {
  let wrapper;

  const createWrapper = (filterOptions, props) => {
    wrapper = shallowMount(ProjectFilterOld, {
      propsData: { filter: { ...filter, ...filterOptions }, ...props },
    });
  };

  const dropdownItems = () => wrapper.findAll(`[data-testid^=${filter.id}]`);
  const filterBody = () => wrapper.find(FilterBody);

  afterEach(() => {
    wrapper.destroy();
  });

  describe('search box', () => {
    it.each`
      phrase     | count | shouldShow
      ${'shows'} | ${20} | ${true}
      ${'hides'} | ${15} | ${false}
    `('$phrase search box if there are $count options', ({ count, shouldShow }) => {
      createWrapper({ options: generateOptions(count) });

      expect(filterBody().props('showSearchBox')).toBe(shouldShow);
    });

    it('filters options when something is typed in the search box', async () => {
      const expectedItems = filter.options.map((x) => x.name).filter((x) => x.includes('1'));
      createWrapper({}, true);
      filterBody().vm.$emit('input', '1');
      await wrapper.vm.$nextTick();

      expect(dropdownItems()).toHaveLength(3);
      expect(dropdownItems().wrappers.map((x) => x.props('text'))).toEqual(expectedItems);
    });
  });
});

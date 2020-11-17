import ScannerFilter from 'ee/security_dashboard/components/filters/scanner_filter.vue';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueRouter from 'vue-router';
import { uniq, sampleSize, difference } from 'lodash';
import { GlLoadingIcon } from '@gitlab/ui';

const localVue = createLocalVue();
localVue.use(VueRouter);
const router = new VueRouter();

const createOptions = (groupName, length) =>
  Array.from({ length }).map((_, i) => ({
    id: `${groupName}${i}`,
    name: `${groupName}-${i}`,
    reportType: `${groupName}Report`,
    externalId: groupName,
  }));

const gitLabOptions = createOptions('GitLab', 8);

const filter = {
  id: 'scanner',
  name: 'scanner',
  options: gitLabOptions.slice(0, 5),
  allOption: { id: 'allOptionId' },
  defaultOptions: [],
};

const customScanners = {
  GitLab: gitLabOptions.slice(5),
  Custom: createOptions('Custom', 3),
};

const customOptions = Object.values(customScanners).flatMap(x => x);

describe('Scanner Filter component', () => {
  let wrapper;

  const findItemWithName = name => wrapper.find(`[text="${name}"]`);
  const findHeaderWithName = name => wrapper.find(`[data-testid="${name}Header"]`);

  const expectSelectedItems = items => {
    const dropdownItems = wrapper.findAll('[data-testid="option"]');

    const checkedItems = dropdownItems.wrappers
      .filter(x => x.props('isChecked'))
      .map(x => x.props('text'));
    const expectedItems = items.map(x => x.name);

    expect(checkedItems.sort()).toEqual(expectedItems.sort());
  };

  const createWrapper = options => {
    wrapper = shallowMount(ScannerFilter, {
      localVue,
      router,
      propsData: { filter },
      provide: { dashboardType: '' },
      data: () => ({ customScanners }),
      mocks: {
        $apollo: {
          queries: {
            customScanners: {},
          },
        },
      },
      ...options,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('has the default and custom option items', () => {
    createWrapper();

    filter.options.concat(customOptions).forEach(option => {
      expect(findItemWithName(option.name).exists()).toBe(true);
    });
  });

  it('toggles selection of all items in a group when the group header is clicked', async () => {
    const selectedOptions = sampleSize(filter.options.concat(customOptions), 7);
    createWrapper();
    wrapper.setData({ selectedOptions });
    await wrapper.vm.$nextTick();

    expectSelectedItems(selectedOptions);

    const clickAndCheck = async expectedOptions => {
      findHeaderWithName('GitLab').trigger('click');
      await wrapper.vm.$nextTick();

      expectSelectedItems(expectedOptions);
    };

    await clickAndCheck(uniq(gitLabOptions.concat(selectedOptions))); // First click selects all.
    await clickAndCheck(difference(selectedOptions, gitLabOptions)); // Second check unselects all.
    await clickAndCheck(uniq(gitLabOptions.concat(selectedOptions))); // Third click selects all again.
  });

  it('updates selected options when customScanner is changed', async () => {
    const selectedOptions = sampleSize(customOptions, 4);
    router.replace({ query: { [filter.id]: selectedOptions.map(x => x.id) } });
    createWrapper();
    wrapper.setData({ selectedOptions });
    await wrapper.vm.$nextTick();

    expectSelectedItems(selectedOptions);
  });

  it('shows loading icon when Apollo query is loading', () => {
    const mocks = { $apollo: { queries: { customScanners: { loading: true } } } };
    createWrapper({ mocks });

    expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
  });

  it('emits filter-changed event with expected data when selected options is changed', async () => {
    const selectedOptions = sampleSize(customOptions, 4);
    createWrapper();
    wrapper.setData({ selectedOptions });
    await wrapper.vm.$nextTick();

    expect(wrapper.emitted('filter-changed')[0][0]).toEqual({
      reportType: expect.arrayContaining(['GitLabReport', 'CustomReport']),
      scanner: expect.arrayContaining(['GitLab', 'Custom']),
    });
  });
});

import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueRouter from 'vue-router';
import ActivityFilter from 'ee/security_dashboard/components/filters/activity_filter.vue';
import { activityFilter, activityOptions } from 'ee/security_dashboard/helpers';

const localVue = createLocalVue();
localVue.use(VueRouter);
const router = new VueRouter();

const { NO_ACTIVITY, WITH_ISSUES, NO_LONGER_DETECTED } = activityOptions;

describe('Activity Filter component', () => {
  let wrapper;

  const findItemWithName = (name) => wrapper.find(`[data-testid="option:${name}"]`);

  const expectSelectedItems = (items) => {
    const checkedItems = wrapper
      .findAll('[data-testid^="option:"]')
      .wrappers.filter((x) => x.props('isChecked'))
      .map((x) => x.props('text'));

    const expectedItems = items.map((x) => x.name);

    expect(checkedItems.sort()).toEqual(expectedItems.sort());
  };

  const createWrapper = () => {
    wrapper = shallowMount(ActivityFilter, {
      localVue,
      router,
      propsData: { filter: activityFilter },
    });
  };

  const clickItem = (item) => {
    findItemWithName(item.name).vm.$emit('click');
  };

  beforeEach(() => {
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
    // Clear out the querystring if one exists, it persists between tests.
    if (router.currentRoute.query[activityFilter.id]) {
      router.replace('/');
    }
  });

  it('renders the options', () => {
    activityFilter.options.forEach((option) => {
      expect(findItemWithName(option.name).exists()).toBe(true);
    });
  });

  it.each`
    selectedOptions                      | expectedOption
    ${[NO_ACTIVITY]}                     | ${WITH_ISSUES}
    ${[WITH_ISSUES, NO_LONGER_DETECTED]} | ${NO_ACTIVITY}
  `(
    'deselects mutually exclusive options when $expectedOption.id is selected',
    async ({ selectedOptions, expectedOption }) => {
      await selectedOptions.map(clickItem);

      expectSelectedItems(selectedOptions);

      await clickItem(expectedOption);

      expectSelectedItems([expectedOption]);
    },
  );

  describe('filter-changed event', () => {
    it('contains the correct filterObject for the all option', async () => {
      // Click on another option first.
      await clickItem(NO_ACTIVITY);
      await clickItem(activityFilter.allOption);

      expect(wrapper.emitted('filter-changed')).toHaveLength(3);
      expect(wrapper.emitted('filter-changed')[2][0]).toStrictEqual({
        hasIssues: undefined,
        hasResolution: undefined,
      });
    });

    it.each`
      selectedOptions                      | hasIssues | hasResolution
      ${[NO_ACTIVITY]}                     | ${false}  | ${false}
      ${[WITH_ISSUES]}                     | ${true}   | ${false}
      ${[NO_LONGER_DETECTED]}              | ${false}  | ${true}
      ${[WITH_ISSUES, NO_LONGER_DETECTED]} | ${true}   | ${true}
    `(
      'contains the correct filterObject for $selectedOptions',
      async ({ selectedOptions, hasIssues, hasResolution }) => {
        await selectedOptions.map(clickItem);

        expectSelectedItems(selectedOptions);
        expect(wrapper.emitted('filter-changed')[1][0]).toEqual({ hasIssues, hasResolution });
      },
    );
  });
});

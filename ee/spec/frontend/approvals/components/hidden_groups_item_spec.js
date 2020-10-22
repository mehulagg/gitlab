import { shallowMount, createLocalVue } from '@vue/test-utils';
import HiddenGroupsItem from 'ee/approvals/components/hidden_groups_item.vue';

const localVue = createLocalVue();

describe('Approvals HiddenGroupsItem', () => {
  let wrapper;

  const factory = (options = {}) => {
    wrapper = shallowMount(localVue.extend(HiddenGroupsItem), {
      ...options,
      localVue,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders successfully', () => {
    factory();

    expect(wrapper.exists()).toBe(true);
  });
});

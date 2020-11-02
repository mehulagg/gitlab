import { shallowMount } from '@vue/test-utils';
import { GlSkeletonLoader } from '@gitlab/ui';
import BoardCardLoading from '~/boards/components/board_card_loading.vue';

describe('BoardCard', () => {
  let wrapper;

  const mountComponent = () => {
    wrapper = shallowMount(BoardCardLoading);
  };

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders GlSkeletonLoader', () => {
    expect(wrapper.find(GlSkeletonLoader).exists()).toBe(true);
  });
});

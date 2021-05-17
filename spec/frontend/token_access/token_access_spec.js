import { GlToggle } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import TokenAccess from '~/token_access/components/token_access.vue';

describe('TokenAccess component', () => {
  let wrapper;

  const findToggle = () => wrapper.findComponent(GlToggle);

  const createComponent = () => {
    wrapper = shallowMount(TokenAccess);
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('should show a toggle', () => {
    expect(findToggle().exists()).toBe(true);
  });
});

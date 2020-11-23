import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SharedRunners from '~/projects/settings/components/shared_runners.vue';

jest.mock('~/flash');

describe('projects/settings/components/shared_runners', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(SharedRunners, {
      propsData: {
        isEnabled: false,
        isDisabledAndUnoverridable: false,
        isLoading: false,
        ...props,
      },
    });
  };

  const disabledMessage = () => wrapper.find('[data-testid="shared-runners-disabled-messages"]');
  const sharedRunnersToggle = () => wrapper.find('[data-testid="toggle-shared-runners"]');
  const loadingIcon = () => wrapper.find(GlLoadingIcon);
  const toggleValue = () => sharedRunnersToggle().props('value');

  beforeEach(() => {
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('with group share settings is DISABLED', () => {
    beforeEach(() => {
      createComponent({
        isDisabledAndUnoverridable: true,
      });
    });

    it('toggle should not exist', () => {
      expect(sharedRunnersToggle().exists()).toBe(false);
    });

    it('disabled message should be displayed', () => {
      expect(disabledMessage().exists()).toBe(true);
    });
  });

  describe('with group share settings is ENABLED', () => {
    beforeEach(() => {
      createComponent();
    });

    it('toggle should exist', () => {
      expect(sharedRunnersToggle().exists()).toBe(true);
    });

    it('loading icon should not exist', () => {
      expect(loadingIcon().exists()).toBe(false);
    });

    it('disabled message should be hidden', () => {
      expect(disabledMessage().exists()).toBe(false);
    });
  });

  describe('with share runners is DISABLED', () => {
    beforeEach(() => {
      createComponent();
    });

    it('toggle should be disabled', () => {
      expect(toggleValue()).toBe(false);
    });

    it('can enable toggle', () => {
      expect(loadingIcon().exists()).toBe(false);
      sharedRunnersToggle().vm.$emit('change', true);
      // TODO
    });
  });

  describe('with share runners is ENABLED', () => {
    beforeEach(() => {
      createComponent({ isEnabled: true });
    });

    it('toggle should be enabled', () => {
      expect(toggleValue()).toBe(true);
    });

    it('can disable toggle', async () => {
      expect(loadingIcon().exists()).toBe(false);
      sharedRunnersToggle().vm.$emit('change', true);
      // TODO
    });
  });
});

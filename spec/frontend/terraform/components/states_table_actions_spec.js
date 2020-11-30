import { GlDropdown } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import StateActions from '~/terraform/components/states_table_actions.vue';

describe('StatesTableActions', () => {
  let wrapper;

  const findDownloadBtn = () => wrapper.find('[data-testid="terraform-state-download"]');

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when state has a latestVersion', () => {
    beforeEach(() => {
      wrapper = shallowMount(StateActions, {
        propsData: {
          state: {
            id: 'gid/1',
            name: 'state-1',
            latestVersion: { downloadPath: '/path' },
          },
        },
        stubs: { GlDropdown },
      });

      return wrapper.vm.$nextTick();
    });

    it('displays a download button', () => {
      const downloadBtn = findDownloadBtn();

      expect(downloadBtn.exists()).toBe(true);
      expect(downloadBtn.text()).toBe('Download latest (JSON)');
    });
  });

  describe('when state does not have a latestVersion', () => {
    beforeEach(() => {
      wrapper = shallowMount(StateActions, {
        propsData: {
          state: {
            id: 'gid/1',
            name: 'state-1',
            latestVersion: null,
          },
        },
        stubs: { GlDropdown },
      });

      return wrapper.vm.$nextTick();
    });

    it('does not display a download button', () => {
      expect(findDownloadBtn().exists()).toBe(false);
    });
  });
});

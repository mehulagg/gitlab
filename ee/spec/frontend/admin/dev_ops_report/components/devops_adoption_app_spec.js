import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import DevopsAdoptionApp from 'ee/admin/dev_ops_report/components/devops_adoption_app.vue';
import DevopsAdoptionEmptyState from 'ee/admin/dev_ops_report/components/devops_adoption_empty_state.vue';

const localVue = createLocalVue();

describe('DevopsAdoptionApp', () => {
  let wrapper;

  const createComponent = (options = {}) => {
    const { loading = true, data = {} } = options;
    return shallowMount(DevopsAdoptionApp, {
      localVue,
      data() {
        return {
          ...data,
        };
      },
      mocks: {
        $apollo: {
          queries: {
            groups: { loading },
          },
        },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when loading', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('does not display the empty state', () => {
      expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
    });

    it('displays the loader', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('when no data is present', () => {
    beforeEach(() => {
      wrapper = createComponent({ loading: false, data: { groups: { nodes: [], pageInfo: {} } } });
    });

    it('displays the empty state', () => {
      expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(true);
    });
  });
});

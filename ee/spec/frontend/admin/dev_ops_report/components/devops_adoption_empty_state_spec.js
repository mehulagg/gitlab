import { shallowMount, mount } from '@vue/test-utils';
import { GlEmptyState, GlButton } from '@gitlab/ui';
import DevopsAdoptionEmptyState from 'ee/admin/dev_ops_report/components/devops_adoption_empty_state.vue';
import {
  DEVOPS_ADOPTION_STRINGS,
  DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
} from 'ee/admin/dev_ops_report/constants';

const emptyStateSvgPath = 'illustrations/monitoring/getting_started.svg';

describe('DevopsAdoptionEmptyState', () => {
  let wrapper;

  const createComponent = (options = {}) => {
    const { stubs = {}, props = {}, func = shallowMount } = options;

    return func(DevopsAdoptionEmptyState, {
      provide: {
        emptyStateSvgPath,
      },
      propsData: {
        hasGroupsData: true,
        ...props,
      },
      stubs,
    });
  };

  const findEmptyState = () => wrapper.find(GlEmptyState);
  const findEmptyStateAction = () => findEmptyState().find(GlButton);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('contains the correct svg', () => {
    wrapper = createComponent();

    expect(findEmptyState().props('svgPath')).toBe(emptyStateSvgPath);
  });

  it('contains the correct text', () => {
    wrapper = createComponent();

    const emptyState = findEmptyState();

    expect(emptyState.props('title')).toBe(DEVOPS_ADOPTION_STRINGS.emptyState.title);
    expect(emptyState.props('description')).toBe(DEVOPS_ADOPTION_STRINGS.emptyState.description);
  });

  describe('action button', () => {
    it('displays an overridden action button', () => {
      wrapper = createComponent({ stubs: { GlEmptyState } });

      const actionButton = findEmptyStateAction();

      expect(actionButton.exists()).toBe(true);
      expect(actionButton.text()).toBe(DEVOPS_ADOPTION_STRINGS.emptyState.button);
    });

    it('is enabled when there is group data', () => {
      wrapper = createComponent({ stubs: { GlEmptyState } });

      const actionButton = findEmptyStateAction();

      expect(actionButton.props('disabled')).toBe(false);
    });

    it('is disabled when there is no group data', () => {
      wrapper = createComponent({ stubs: { GlEmptyState }, props: { hasGroupsData: false } });

      const actionButton = findEmptyStateAction();

      expect(actionButton.props('disabled')).toBe(true);
    });

    it('calls the gl-modal show', async () => {
      wrapper = createComponent({ func: mount });

      const actionButton = findEmptyStateAction();
      const rootEmit = jest.spyOn(wrapper.vm.$root, '$emit');

      actionButton.trigger('click');

      expect(rootEmit.mock.calls[0][0]).toContain('show');
      expect(rootEmit.mock.calls[0][1]).toBe(DEVOPS_ADOPTION_SEGMENT_MODAL_ID);
    });
  });
});

import { GlEmptyState, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AgentEmptyState from 'ee/clusters_list/components/agent_empty_state.vue';

describe('AgentEmptyStateComponent', () => {
  let wrapper;

  const propsData = {
    image: '/image/path',
  };

  beforeEach(() => {
    wrapper = shallowMount(AgentEmptyState, { propsData, stubs: { GlEmptyState, GlSprintf } });
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  it('should render content', () => {
    expect(wrapper.find(GlEmptyState).exists()).toBe(true);
    expect(wrapper.text()).toContain('Integrate with the GitLab Agent');
  });
});

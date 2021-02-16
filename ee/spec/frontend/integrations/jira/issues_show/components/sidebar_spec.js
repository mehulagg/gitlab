import { shallowMount } from '@vue/test-utils';

import Sidebar from 'ee/integrations/jira/issues_show/components/sidebar.vue';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';

import { mockJiraIssue } from '../mock_data';

describe('Sidebar', () => {
  let wrapper;

  const defaultProps = {
    sidebarExpanded: false,
    selectedLabels: mockJiraIssue.labels,
  };

  const createComponent = () => {
    wrapper = shallowMount(Sidebar, {
      propsData: defaultProps,
    });
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findLabelsSelect = () => wrapper.findComponent(LabelsSelect);

  it('renders LabelsSelect', async () => {
    createComponent();

    await wrapper.vm.$nextTick();

    expect(findLabelsSelect().exists()).toBe(true);
  });
});

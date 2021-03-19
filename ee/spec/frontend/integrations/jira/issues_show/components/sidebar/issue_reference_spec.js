import { shallowMount } from '@vue/test-utils';

import IssueReference from 'ee/integrations/jira/issues_show/components/sidebar/issue_reference.vue';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

describe('IssueReference', () => {
  let wrapper;

  const defaultProps = {
    reference: 'GL-1',
  };

  const createComponent = () => {
    wrapper = shallowMount(IssueReference, {
      propsData: defaultProps,
    });
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findClipboardButton = () => wrapper.findComponent(ClipboardButton);

  it('renders reference', () => {
    createComponent();

    expect(wrapper.text()).toContain(defaultProps.reference);
  });

  it('renders ClipboardButton', () => {
    createComponent();

    expect(findClipboardButton().exists()).toBe(true);
  });
});

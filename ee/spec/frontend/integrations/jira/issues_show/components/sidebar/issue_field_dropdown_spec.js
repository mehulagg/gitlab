import { GlDropdownItem, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import IssueFieldDropdown from 'ee/integrations/jira/issues_show/components/sidebar/issue_field_dropdown.vue';

import { mockJiraIssueStatuses } from '../../mock_data';

describe('IssueFieldDropdown', () => {
  let wrapper;

  const emptyText = 'empty text';
  const defaultProps = {
    emptyText,
    text: 'issue field text',
    title: 'issue field header text',
  };

  const createComponent = ({ props = {} } = {}) => {
    wrapper = shallowMount(IssueFieldDropdown, {
      propsData: { ...defaultProps, ...props },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findAllGlDropdownItems = () => wrapper.findAllComponents(GlDropdownItem);
  const findGlLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);

  it.each`
    loading  | items
    ${true}  | ${[]}
    ${true}  | ${mockJiraIssueStatuses}
    ${false} | ${[]}
    ${false} | ${mockJiraIssueStatuses}
  `('with loading = $loading, items = $items', ({ loading, items }) => {
    createComponent({
      props: {
        loading,
        items,
      },
    });

    expect(findGlLoadingIcon().exists()).toBe(loading);

    if (!loading) {
      if (items.length) {
        findAllGlDropdownItems().wrappers.forEach((itemWrapper, index) => {
          expect(itemWrapper.text()).toBe(mockJiraIssueStatuses[index].title);
        });
      } else {
        expect(wrapper.text()).toBe(emptyText);
      }
    }
  });
});

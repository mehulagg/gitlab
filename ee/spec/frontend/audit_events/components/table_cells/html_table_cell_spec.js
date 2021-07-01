import { shallowMount } from '@vue/test-utils';

import HtmlTableCell from 'ee/audit_events/components/table_cells/html_table_cell.vue';

describe('HtmlTableCell component', () => {
  it('should not include tags that are not in the allowed list but should keep the content', () => {
    const html =
      '<a href="https://magic.url/">Link</a> <i>Test</i> <h1>HTML</h1> <strong>Flex</strong>';
    const wrapper = shallowMount(HtmlTableCell, {
      propsData: { html },
    });

    expect(wrapper.html()).toBe('<span>Link Test HTML Flex</span>');
  });
});

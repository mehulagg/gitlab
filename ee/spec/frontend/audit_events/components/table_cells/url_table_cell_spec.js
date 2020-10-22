import { shallowMount } from '@vue/test-utils';

import UrlTableCell from 'ee/audit_events/components/table_cells/url_table_cell.vue';

describe('UrlTableCell component', () => {
  it('should show the link if the URL is provided', () => {
    const wrapper = shallowMount(UrlTableCell, { propsData: { url: '/user-1', name: 'User 1' } });
    const name = wrapper.find('a');

    expect(name.exists()).toBe(true);
    expect(name.attributes().href).toBe('/user-1');
    expect(name.text()).toBe('User 1');
  });

  it('should show the removed text if no URL is provided', () => {
    const wrapper = shallowMount(UrlTableCell, { propsData: { url: '', name: 'User 1' } });
    const name = wrapper.find('span');

    expect(name.exists()).toBe(true);
    expect(name.text()).toBe('User 1 (removed)');
  });
});

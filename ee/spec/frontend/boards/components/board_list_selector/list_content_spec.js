import { shallowMount } from '@vue/test-utils';
import ListContent from 'ee/boards/components/boards_list_selector/list_content.vue';
import { mockAssigneesList } from 'jest/boards/mock_data';

describe('ListContent', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(ListContent, {
      propsData: {
        items: mockAssigneesList,
        listType: 'assignees',
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('emits `onItemSelect` event on component and sends `assignee` as event param', () => {
    const assignee = mockAssigneesList[0];

    wrapper.vm.handleItemClick(assignee);

    expect(wrapper.emitted().onItemSelect[0]).toEqual([assignee]);
  });

  it('renders component container element with class `dropdown-content`', () => {
    expect(wrapper.classes('dropdown-content')).toBe(true);
  });

  it('renders UL parent element as child within container', () => {
    expect(wrapper.find('ul').exists()).toBe(true);
  });
});

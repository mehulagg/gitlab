import { shallowMount } from '@vue/test-utils';
import { GlSearchBoxByType } from '@gitlab/ui';
import GroupSelect from '~/invite_members/components/group_select.vue';
import Api from '~/api';

const createComponent = () => {
  return shallowMount(GroupSelect, {});
};

const group1 = { id: 1, name: 'Group One' };
const group2 = { id: 2, name: 'Group Two' };
const allGroups = [group1, group2];

describe('GroupSelect', () => {
  let wrapper;

  beforeEach(() => {
    jest.spyOn(Api, 'groups').mockResolvedValue({ data: allGroups });

    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findSearchBoxByType = () => wrapper.find(GlSearchBoxByType);

  it('renders GlSearchBoxByType with default attributes', () => {
    expect(findSearchBoxByType().exists()).toBe(true);
    expect(findSearchBoxByType().vm.$attrs).toMatchObject({
      placeholder: 'Search groups',
    });
  });

  describe('when modal is opened', () => {
    it('calls the API to get the list of groups', async () => {
      expect(Api.groups).toHaveBeenCalled();
    });
  });
});

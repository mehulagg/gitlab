import { mount } from '@vue/test-utils';
import $ from 'jquery';
import 'bootstrap';
import '~/gl_dropdown';
import GroupsDropdownFilter from 'ee/analytics/shared/components/groups_dropdown_filter.vue';
import { TEST_HOST } from 'helpers/test_constants';
import Api from '~/api';

jest.mock('~/api', () => ({
  groups: jest.fn(),
}));

const groups = [
  {
    id: 1,
    name: 'foo',
    full_name: 'foo',
    avatar_url: `${TEST_HOST}/images/home/nasa.svg`,
  },
  {
    id: 2,
    name: 'subgroup',
    full_name: 'group / subgroup',
    avatar_url: null,
  },
];

describe('GroupsDropdownFilter component', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = mount(GroupsDropdownFilter, {
      sync: false,
      propsData: {
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  beforeEach(() => {
    jest.spyOn($.fn, 'glDropdown');
    Api.groups.mockImplementation((term, options, callback) => {
      callback(groups);
    });
  });

  const findDropdown = () => wrapper.find({ ref: 'groupsDropdown' });
  const openDropdown = () => {
    $(findDropdown().element)
      .parent()
      .trigger('shown.bs.dropdown');
  };
  const findDropdownItems = () => findDropdown().findAll('a');
  const findDropdownButton = () => findDropdown().find('button');
  const findDropdownButtonAvatar = () => findDropdown().find('.gl-avatar');

  it('should call glDropdown', () => {
    createComponent();
    expect($.fn.glDropdown).toHaveBeenCalled();
  });

  describe('when passed a defaultGroup as prop', () => {
    beforeEach(() => {
      createComponent({
        defaultGroup: groups[0],
      });
    });

    it("displays the defaultGroup's name", () => {
      expect(findDropdownButton().text()).toContain(groups[0].name);
    });

    it("renders the defaultGroup's avatar", () => {
      expect(findDropdownButtonAvatar().exists()).toBe(true);
    });
  });

  describe('it renders the items correctly', () => {
    beforeEach(() => {
      createComponent();

      openDropdown();

      return wrapper.vm.$nextTick();
    });

    it('should contain 2 items', () => {
      expect(findDropdownItems().length).toEqual(2);
    });

    it('renders an avatar when the group has an avatar_url', () => {
      expect(
        findDropdownItems()
          .at(0)
          .contains('img.avatar'),
      ).toBe(true);
      expect(
        findDropdownItems()
          .at(0)
          .contains('div.identicon'),
      ).toBe(false);
    });

    it("renders an identicon when the group doesn't have an avatar_url", () => {
      expect(
        findDropdownItems()
          .at(1)
          .contains('img.avatar'),
      ).toBe(false);
      expect(
        findDropdownItems()
          .at(1)
          .contains('div.identicon'),
      ).toBe(true);
    });

    it('renders the full group name and highlights the last part', () => {
      expect(
        findDropdownItems()
          .at(1)
          .find('.js-group-path')
          .html(),
      ).toContain('group / <strong>subgroup</strong>');
    });
  });

  describe('on group click', () => {
    beforeEach(() => {
      createComponent();

      openDropdown();

      return wrapper.vm.$nextTick();
    });

    it('should emit the "selected" event with the selected group', () => {
      findDropdownItems()
        .at(0)
        .trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emittedByOrder()).toEqual([
          {
            name: 'selected',
            args: [groups[0]],
          },
        ]);
      });
    });

    it('should change selection when new group is clicked', () => {
      findDropdownItems()
        .at(1)
        .trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emittedByOrder()).toEqual([
          {
            name: 'selected',
            args: [groups[1]],
          },
        ]);
      });
    });

    it('renders an avatar in the dropdown button when the group has an avatar_url', done => {
      findDropdownItems()
        .at(0)
        .trigger('click');

      wrapper.vm.$nextTick(() => {
        expect(findDropdownButton().contains('img.gl-avatar')).toBe(true);
        expect(findDropdownButton().contains('.gl-avatar-identicon')).toBe(false);
        done();
      });
    });

    it("renders an identicon in the dropdown button when the group doesn't have an avatar_url", done => {
      findDropdownItems()
        .at(1)
        .trigger('click');

      wrapper.vm.$nextTick(() => {
        expect(findDropdownButton().contains('img.gl-avatar')).toBe(false);
        expect(findDropdownButton().contains('.gl-avatar-identicon')).toBe(true);
        done();
      });
    });
  });
});

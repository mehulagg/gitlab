import { mount } from '@vue/test-utils';
import ProjectsDropdownFilter from 'ee/analytics/shared/components/projects_dropdown_filter.vue';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { LAST_ACTIVITY_AT } from 'ee/analytics/shared/constants';
import { TEST_HOST } from 'helpers/test_constants';
import Api from '~/api';

jest.mock('~/api', () => ({
  groupProjects: jest.fn(),
}));

const projects = [
  {
    id: 1,
    name: 'foo',
    avatar_url: `${TEST_HOST}/images/home/nasa.svg`,
  },
  {
    id: 2,
    name: 'foobar',
    avatar_url: null,
  },
  {
    id: 3,
    name: 'foooooooo',
    avatar_url: null,
  },
];

describe('ProjectsDropdownFilter component', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = mount(ProjectsDropdownFilter, {
      propsData: {
        groupId: 1,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  beforeEach(() => {
    Api.groupProjects.mockImplementation((groupId, term, options, callback) => {
      callback(projects);
    });
  });

  const findDropdown = () => wrapper.find(GlDropdown);

  const findDropdownItems = () =>
    findDropdown()
      .findAll(GlDropdownItem)
      .filter(w => w.text() !== 'No matching results');

  const findDropdownAtIndex = index => findDropdownItems().at(index);

  const findDropdownButton = () => findDropdown().find('.dropdown-toggle');
  const findDropdownButtonAvatar = () => findDropdown().find('.gl-avatar');

  const selectDropdownItemAtIndex = index =>
    findDropdownAtIndex(index)
      .find('button')
      .trigger('click');

  describe('queryParams are applied when fetching data', () => {
    beforeEach(() => {
      createComponent({
        queryParams: {
          per_page: 50,
          with_shared: false,
          order_by: LAST_ACTIVITY_AT,
        },
      });
    });

    it('applies the correct queryParams when making an api call', () => {
      expect(Api.groupProjects).toHaveBeenCalledWith(
        expect.any(Number),
        expect.any(String),
        expect.objectContaining({ per_page: 50, with_shared: false, order_by: LAST_ACTIVITY_AT }),
        expect.any(Function),
      );
    });
  });

  describe('when passed a an array of defaultProject as prop', () => {
    beforeEach(() => {
      createComponent({
        defaultProjects: [projects[0]],
      });
    });

    it("displays the defaultProject's name", () => {
      expect(findDropdownButton().text()).toContain(projects[0].name);
    });

    it("renders the defaultProject's avatar", () => {
      expect(findDropdownButtonAvatar().exists()).toBe(true);
    });

    it('marks the defaultProject as selected', () => {
      expect(findDropdownAtIndex(0).props('isChecked')).toBe(true);
    });
  });

  describe('when multiSelect is false', () => {
    beforeEach(() => {
      createComponent({ multiSelect: false });
    });

    describe('displays the correct information', () => {
      it('contains 3 items', () => {
        expect(findDropdownItems()).toHaveLength(3);
      });

      it('renders an avatar when the project has an avatar_url', () => {
        expect(
          findDropdownAtIndex(0)
            .find('img.gl-avatar')
            .exists(),
        ).toBe(true);
        expect(
          findDropdownAtIndex(0)
            .find('div.gl-avatar-identicon')
            .exists(),
        ).toBe(false);
      });
      it("renders an identicon when the project doesn't have an avatar_url", () => {
        expect(
          findDropdownAtIndex(1)
            .find('img.gl-avatar')
            .exists(),
        ).toBe(false);
        expect(
          findDropdownAtIndex(1)
            .find('div.gl-avatar-identicon')
            .exists(),
        ).toBe(true);
      });
    });

    describe('on project click', () => {
      it('should emit the "selected" event with the selected project', () => {
        selectDropdownItemAtIndex(0);

        expect(wrapper.emitted().selected).toEqual([[[projects[0]]]]);
      });

      it('should change selection when new project is clicked', () => {
        selectDropdownItemAtIndex(1);

        expect(wrapper.emitted().selected).toEqual([[[projects[1]]]]);
      });

      it('selection should be emptied when a project is deselected', () => {
        selectDropdownItemAtIndex(0); // Select the item
        selectDropdownItemAtIndex(0); // deselect it

        expect(wrapper.emitted().selected).toEqual([[[projects[0]]], [[]]]);
      });

      it('renders an avatar in the dropdown button when the project has an avatar_url', () => {
        selectDropdownItemAtIndex(0);

        return wrapper.vm.$nextTick().then(() => {
          expect(
            findDropdownButton()
              .find('img.gl-avatar')
              .exists(),
          ).toBe(true);
          expect(
            findDropdownButton()
              .find('.gl-avatar-identicon')
              .exists(),
          ).toBe(false);
        });
      });

      it("renders an identicon in the dropdown button when the project doesn't have an avatar_url", () => {
        selectDropdownItemAtIndex(1);

        return wrapper.vm.$nextTick().then(() => {
          expect(
            findDropdownButton()
              .find('img.gl-avatar')
              .exists(),
          ).toBe(false);
          expect(
            findDropdownButton()
              .find('.gl-avatar-identicon')
              .exists(),
          ).toBe(true);
        });
      });
    });
  });

  describe('when multiSelect is true', () => {
    beforeEach(() => {
      createComponent({ multiSelect: true });
    });

    describe('displays the correct information', () => {
      it('contains 3 items', () => {
        expect(findDropdownItems()).toHaveLength(3);
      });

      it('renders an avatar when the project has an avatar_url', () => {
        expect(
          findDropdownAtIndex(0)
            .find('img.gl-avatar')
            .exists(),
        ).toBe(true);
        expect(
          findDropdownAtIndex(0)
            .find('div.gl-avatar-identicon')
            .exists(),
        ).toBe(false);
      });

      it("renders an identicon when the project doesn't have an avatar_url", () => {
        expect(
          findDropdownAtIndex(1)
            .find('img.gl-avatar')
            .exists(),
        ).toBe(false);
        expect(
          findDropdownAtIndex(1)
            .find('div.gl-avatar-identicon')
            .exists(),
        ).toBe(true);
      });
    });

    describe('on project click', () => {
      it('should add to selection when new project is clicked', () => {
        selectDropdownItemAtIndex(0);
        selectDropdownItemAtIndex(1);

        expect(wrapper.emitted().selected).toEqual([[[projects[0]]], [[projects[0], projects[1]]]]);
      });

      it('should remove from selection when clicked again', () => {
        selectDropdownItemAtIndex(0);
        selectDropdownItemAtIndex(0);

        expect(wrapper.emitted().selected).toEqual([[[projects[0]]], [[]]]);
      });

      it('renders the correct placeholder text when multiple projects are selected', () => {
        selectDropdownItemAtIndex(0);
        selectDropdownItemAtIndex(1);

        return wrapper.vm.$nextTick().then(() => {
          expect(findDropdownButton().text()).toBe('2 projects selected');
        });
      });
    });
  });
});

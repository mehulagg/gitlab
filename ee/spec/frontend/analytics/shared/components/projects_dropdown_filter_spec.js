import $ from 'jquery';
import 'bootstrap';
import { mount } from '@vue/test-utils';
import ProjectsDropdownFilter from 'ee/analytics/shared/components/projects_dropdown_filter.vue';
import { LAST_ACTIVITY_AT } from 'ee/analytics/shared/constants';
import { TEST_HOST } from 'helpers/test_constants';
import Api from '~/api';
import '~/gl_dropdown';

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
      sync: false,
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
    jest.spyOn($.fn, 'glDropdown');
    Api.groupProjects.mockImplementation((groupId, term, options, callback) => {
      callback(projects);
    });
  });

  const findDropdown = () => wrapper.find({ ref: 'projectsDropdown' });
  const openDropdown = () => {
    $(findDropdown().element)
      .parent()
      .trigger('shown.bs.dropdown');
  };
  const findDropdownItems = () => findDropdown().findAll('a');
  const findDropdownButton = () => findDropdown().find('button');
  const findDropdownButtonAvatar = () => findDropdown().find('.gl-avatar');

  describe('queryParams are applied when fetching data', () => {
    beforeEach(() => {
      createComponent({
        queryParams: {
          per_page: 50,
          with_shared: false,
          order_by: LAST_ACTIVITY_AT,
        },
      });

      openDropdown();

      return wrapper.vm.$nextTick();
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
      openDropdown();

      return wrapper.vm.$nextTick().then(() => {
        expect(
          findDropdownItems()
            .at(0)
            .classes('is-active'),
        ).toBe(true);
      });
    });
  });

  describe('when multiSelect is false', () => {
    beforeEach(() => {
      createComponent({ multiSelect: false });
    });

    it('calls glDropdown', () => {
      expect($.fn.glDropdown).toHaveBeenCalled();
    });

    describe('displays the correct information', () => {
      beforeEach(() => {
        openDropdown();

        return wrapper.vm.$nextTick();
      });

      it('contains 3 items', () => {
        expect(findDropdownItems().length).toEqual(3);
      });

      it('renders an avatar when the project has an avatar_url', () => {
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

      it("renders an identicon when the project doesn't have an avatar_url", () => {
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
    });

    describe('on project click', () => {
      beforeEach(() => {
        openDropdown();

        return wrapper.vm.$nextTick();
      });

      it('should emit the "selected" event with the selected project', () => {
        findDropdownItems()
          .at(0)
          .trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emittedByOrder()).toEqual([
            {
              name: 'selected',
              args: [[projects[0]]],
            },
          ]);
        });
      });

      it('should change selection when new project is clicked', () => {
        findDropdownItems()
          .at(1)
          .trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emittedByOrder()).toEqual([
            {
              name: 'selected',
              args: [[projects[1]]],
            },
          ]);
        });
      });

      it('selection should be emptied when a project is deselected', () => {
        const project = findDropdownItems().at(0);
        project.trigger('click');
        project.trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emittedByOrder()).toEqual([
            {
              name: 'selected',
              args: [[projects[0]]],
            },
            {
              name: 'selected',
              args: [[]],
            },
          ]);
        });
      });

      it('renders an avatar in the dropdown button when the project has an avatar_url', done => {
        findDropdownItems()
          .at(0)
          .trigger('click');

        wrapper.vm.$nextTick(() => {
          expect(findDropdownButton().contains('img.gl-avatar')).toBe(true);
          expect(findDropdownButton().contains('.gl-avatar-identicon')).toBe(false);
          done();
        });
      });

      it("renders an identicon in the dropdown button when the project doesn't have an avatar_url", done => {
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

  describe('when multiSelect is true', () => {
    beforeEach(() => {
      createComponent({ multiSelect: true });
    });

    describe('displays the correct information', () => {
      beforeEach(() => {
        openDropdown();

        return wrapper.vm.$nextTick();
      });

      it('contains 3 items', () => {
        expect(findDropdownItems().length).toEqual(3);
      });

      it('renders an avatar when the project has an avatar_url', () => {
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

      it("renders an identicon when the project doesn't have an avatar_url", () => {
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
    });

    describe('on project click', () => {
      beforeEach(() => {
        openDropdown();

        return wrapper.vm.$nextTick();
      });

      it('should add to selection when new project is clicked', () => {
        findDropdownItems()
          .at(0)
          .trigger('click');

        return wrapper.vm
          .$nextTick()
          .then(() => {
            findDropdownItems()
              .at(1)
              .trigger('click');
            return wrapper.vm.$nextTick();
          })
          .then(() => {
            expect(wrapper.emittedByOrder()).toEqual([
              {
                name: 'selected',
                args: [[projects[0]]],
              },
              {
                name: 'selected',
                args: [[projects[0], projects[1]]],
              },
            ]);
          });
      });

      it('should remove from selection when clicked again', () => {
        const item = findDropdownItems().at(0);

        item.trigger('click');
        item.trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emittedByOrder()).toEqual([
            {
              name: 'selected',
              args: [[projects[0]]],
            },
            {
              name: 'selected',
              args: [[]],
            },
          ]);
        });
      });

      it('renders the correct placeholder text when multiple projects are selected', done => {
        findDropdownItems()
          .at(0)
          .trigger('click');
        return wrapper.vm
          .$nextTick()
          .then(() => {
            findDropdownItems()
              .at(1)
              .trigger('click');
            return wrapper.vm.$nextTick();
          })
          .then(() => {
            expect(findDropdownButton().text()).toBe('2 projects selected');
            done();
          });
      });
    });
  });
});

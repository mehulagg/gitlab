import { mount } from '@vue/test-utils';
import ProjectsDropdownFilter from 'ee/analytics/shared/components/projects_dropdown_filter.vue';
import getProjects from 'ee/analytics/shared/graphql/projects.query.graphql';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { LAST_ACTIVITY_AT } from 'ee/analytics/shared/constants';
import { TEST_HOST } from 'helpers/test_constants';
import Api from '~/api';

jest.mock('~/api', () => ({
  groupProjects: jest.fn(),
}));

const mockGraphqlProjects = [
  {
    id: 'gid://gitlab/Project/1',
    name: 'Gitlab Test',
    fullPath: 'gitlab-org/gitlab-test',
    avatarUrl: `${TEST_HOST}/images/home/nasa.svg`,
  },
  {
    id: 'gid://gitlab/Project/2',
    name: 'Gitlab Shell',
    fullPath: 'gitlab-org/gitlab-shell',
    avatarUrl: null,
  },
  {
    id: 'gid://gitlab/Project/3',
    name: 'Foo',
    fullPath: 'gitlab-org/foo',
    avatarUrl: null,
  },
];

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

const defaultMocks = {
  $apollo: {
    query: jest.fn().mockResolvedValue({
      data: { group: { projects: { nodes: mockGraphqlProjects } } },
    }),
  },
};

let spyQuery;

describe('ProjectsDropdownFilter component', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    spyQuery = defaultMocks.$apollo.query;
    wrapper = mount(ProjectsDropdownFilter, {
      mocks: { ...defaultMocks },
      propsData: {
        groupId: 1,
        groupNamespace: 'gitlab-org',
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findDropdown = () => wrapper.find(GlDropdown);

  const findDropdownItems = () =>
    findDropdown()
      .findAll(GlDropdownItem)
      .filter(w => w.text() !== 'No matching results');

  const findDropdownAtIndex = index => findDropdownItems().at(index);

  const findDropdownButton = () => findDropdown().find('.dropdown-toggle');
  const findDropdownButtonAvatar = () => findDropdown().find('.gl-avatar');
  const findDropdownButtonAvatarAtIndex = index => findDropdownAtIndex(index).find('img.gl-avatar');
  const findDropdownButtonIdentIconAtIndex = index =>
    findDropdownAtIndex(index).find('div.gl-avatar-identicon');

  const selectDropdownItemAtIndex = index =>
    findDropdownAtIndex(index)
      .find('button')
      .trigger('click');

  describe('when using the REST API', () => {
    describe('queryParams are applied when fetching data', () => {
      beforeEach(() => {
        Api.groupProjects.mockImplementation((groupId, term, options, callback) => {
          callback(projects);
        });

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
  });

  describe('when using the GraphQL API', () => {
    beforeEach(() => {
      createComponent({
        useGraphql: true,
        queryParams: {
          first: 50,
          includeSubgroups: true,
        },
      });
    });

    it('applies the correct queryParams when making an api call', async () => {
      wrapper.setData({ searchTerm: 'gitlab' });

      expect(spyQuery).toHaveBeenCalledTimes(1);

      await wrapper.vm.$nextTick(() => {
        expect(spyQuery).toHaveBeenCalledWith({
          query: getProjects,
          variables: {
            search: 'gitlab',
            groupFullPath: wrapper.vm.groupNamespace,
            first: 50,
            includeSubgroups: true,
          },
        });
      });
    });
  });

  describe('when passed a an array of defaultProject as prop', () => {
    describe('when using the RESTP API', () => {
      beforeEach(() => {
        Api.groupProjects.mockImplementation((groupId, term, options, callback) => {
          callback(projects);
        });

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

    describe('when using the GraphQL API', () => {
      beforeEach(() => {
        createComponent({
          useGraphql: true,
          defaultProjects: [mockGraphqlProjects[0]],
        });
      });

      it("displays the defaultProject's name", () => {
        expect(findDropdownButton().text()).toContain(mockGraphqlProjects[0].name);
      });

      it("renders the defaultProject's avatar", () => {
        expect(findDropdownButtonAvatar().exists()).toBe(true);
      });

      it('marks the defaultProject as selected', () => {
        expect(findDropdownAtIndex(0).props('isChecked')).toBe(true);
      });
    });
  });

  describe('when multiSelect is false', () => {
    describe('when using the RESTP API', () => {
      beforeEach(() => {
        Api.groupProjects.mockImplementation((groupId, term, options, callback) => {
          callback(projects);
        });

        createComponent({ multiSelect: false });
      });

      describe('displays the correct information', () => {
        it('contains 3 items', () => {
          expect(findDropdownItems()).toHaveLength(3);
        });

        it('renders an avatar when the project has an avatar_url', () => {
          expect(findDropdownButtonAvatarAtIndex(0).exists()).toBe(true);
          expect(findDropdownButtonIdentIconAtIndex(0).exists()).toBe(false);
        });
        it("renders an identicon when the project doesn't have an avatar_url", () => {
          expect(findDropdownButtonAvatarAtIndex(1).exists()).toBe(false);
          expect(findDropdownButtonIdentIconAtIndex(1).exists()).toBe(true);
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

        it('renders an avatar in the dropdown button when the project has an avatar_url', async () => {
          selectDropdownItemAtIndex(0);

          await wrapper.vm.$nextTick().then(() => {
            expect(
              findDropdownButton()
                .find('img.gl-avatar')
                .exists(),
            ).toBe(true);
            expect(findDropdownButtonIdentIconAtIndex(0).exists()).toBe(false);
          });
        });

        it("renders an identicon in the dropdown button when the project doesn't have an avatar_url", async () => {
          selectDropdownItemAtIndex(1);

          await wrapper.vm.$nextTick().then(() => {
            expect(
              findDropdownButton()
                .find('img.gl-avatar')
                .exists(),
            ).toBe(false);
            expect(findDropdownButtonIdentIconAtIndex(1).exists()).toBe(true);
          });
        });
      });
    });

    describe('when using the GraphQl API', () => {
      beforeEach(() => {
        createComponent({ multiSelect: false, useGraphql: true });
      });

      describe('displays the correct information', () => {
        it('contains 3 items', () => {
          expect(findDropdownItems()).toHaveLength(3);
        });

        it('renders an avatar when the project has an avatarUrl', () => {
          expect(findDropdownButtonAvatarAtIndex(0).exists()).toBe(true);
          expect(findDropdownButtonIdentIconAtIndex(0).exists()).toBe(false);
        });
        it("renders an identicon when the project doesn't have an avatarUrl", () => {
          expect(findDropdownButtonAvatarAtIndex(1).exists()).toBe(false);
          expect(findDropdownButtonIdentIconAtIndex(1).exists()).toBe(true);
        });
      });

      describe('on project click', () => {
        it('should emit the "selected" event with the selected project', () => {
          selectDropdownItemAtIndex(0);

          expect(wrapper.emitted().selected).toEqual([[[mockGraphqlProjects[0]]]]);
        });

        it('should change selection when new project is clicked', () => {
          selectDropdownItemAtIndex(1);

          expect(wrapper.emitted().selected).toEqual([[[mockGraphqlProjects[1]]]]);
        });

        it('selection should be emptied when a project is deselected', () => {
          selectDropdownItemAtIndex(0); // Select the item
          selectDropdownItemAtIndex(0); // deselect it

          expect(wrapper.emitted().selected).toEqual([[[mockGraphqlProjects[0]]], [[]]]);
        });

        it('renders an avatar in the dropdown button when the project has an avatarUrl', async () => {
          selectDropdownItemAtIndex(0);

          await wrapper.vm.$nextTick().then(() => {
            expect(
              findDropdownButton()
                .find('img.gl-avatar')
                .exists(),
            ).toBe(true);
            expect(findDropdownButtonIdentIconAtIndex(0).exists()).toBe(false);
          });
        });

        it("renders an identicon in the dropdown button when the project doesn't have an avatarUrl", async () => {
          selectDropdownItemAtIndex(1);

          await wrapper.vm.$nextTick().then(() => {
            expect(
              findDropdownButton()
                .find('img.gl-avatar')
                .exists(),
            ).toBe(false);
            expect(findDropdownButtonIdentIconAtIndex(1).exists()).toBe(true);
          });
        });
      });
    });
  });

  describe('when multiSelect is true', () => {
    describe('when using the RESTP API', () => {
      beforeEach(() => {
        Api.groupProjects.mockImplementation((groupId, term, options, callback) => {
          callback(projects);
        });

        createComponent({ multiSelect: true });
      });

      describe('displays the correct information', () => {
        it('contains 3 items', () => {
          expect(findDropdownItems()).toHaveLength(3);
        });

        it('renders an avatar when the project has an avatar_url', () => {
          expect(findDropdownButtonAvatarAtIndex(0).exists()).toBe(true);
          expect(findDropdownButtonIdentIconAtIndex(0).exists()).toBe(false);
        });

        it("renders an identicon when the project doesn't have an avatar_url", () => {
          expect(findDropdownButtonAvatarAtIndex(1).exists()).toBe(false);
          expect(findDropdownButtonIdentIconAtIndex(1).exists()).toBe(true);
        });
      });

      describe('on project click', () => {
        it('should add to selection when new project is clicked', () => {
          selectDropdownItemAtIndex(0);
          selectDropdownItemAtIndex(1);

          expect(wrapper.emitted().selected).toEqual([
            [[projects[0]]],
            [[projects[0], projects[1]]],
          ]);
        });

        it('should remove from selection when clicked again', () => {
          selectDropdownItemAtIndex(0);
          selectDropdownItemAtIndex(0);

          expect(wrapper.emitted().selected).toEqual([[[projects[0]]], [[]]]);
        });

        it('renders the correct placeholder text when multiple projects are selected', async () => {
          selectDropdownItemAtIndex(0);
          selectDropdownItemAtIndex(1);

          await wrapper.vm.$nextTick().then(() => {
            expect(findDropdownButton().text()).toBe('2 projects selected');
          });
        });
      });
    });

    describe('when using the GraphQl API', () => {
      beforeEach(() => {
        createComponent({ multiSelect: true, useGraphql: true });
      });

      describe('displays the correct information', () => {
        it('contains 3 items', () => {
          expect(findDropdownItems()).toHaveLength(3);
        });

        it('renders an avatar when the project has an avatarUrl', () => {
          expect(findDropdownButtonAvatarAtIndex(0).exists()).toBe(true);
          expect(findDropdownButtonIdentIconAtIndex(0).exists()).toBe(false);
        });

        it("renders an identicon when the project doesn't have an avatarUrl", () => {
          expect(findDropdownButtonAvatarAtIndex(1).exists()).toBe(false);
          expect(findDropdownButtonIdentIconAtIndex(1).exists()).toBe(true);
        });
      });

      describe('on project click', () => {
        it('should add to selection when new project is clicked', () => {
          selectDropdownItemAtIndex(0);
          selectDropdownItemAtIndex(1);

          expect(wrapper.emitted().selected).toEqual([
            [[mockGraphqlProjects[0]]],
            [[mockGraphqlProjects[0], mockGraphqlProjects[1]]],
          ]);
        });

        it('should remove from selection when clicked again', () => {
          selectDropdownItemAtIndex(0);
          selectDropdownItemAtIndex(0);

          expect(wrapper.emitted().selected).toEqual([[[mockGraphqlProjects[0]]], [[]]]);
        });

        it('renders the correct placeholder text when multiple projects are selected', async () => {
          selectDropdownItemAtIndex(0);
          selectDropdownItemAtIndex(1);

          await wrapper.vm.$nextTick().then(() => {
            expect(findDropdownButton().text()).toBe('2 projects selected');
          });
        });
      });
    });
  });
});

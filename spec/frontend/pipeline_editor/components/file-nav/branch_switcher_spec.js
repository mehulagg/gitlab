import { GlDropdown, GlDropdownItem, GlIcon } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import BranchSwitcher from '~/pipeline_editor/components/file_nav/branch_switcher.vue';
import { mockDefaultBranch, mockProjectBranches, mockProjectFullPath } from '../../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Pipeline editor branch switcher', () => {
  let wrapper;
  let mockApollo;
  let mockAvailableBranchQuery;

  const createComponentWithApollo = () => {
    const resolvers = {
      Query: {
        project: mockAvailableBranchQuery,
      },
    };

    mockApollo = createMockApollo([], resolvers);
    wrapper = shallowMount(BranchSwitcher, {
      localVue,
      apolloProvider: mockApollo,
      provide: {
        projectFullPath: mockProjectFullPath,
      },
      data() {
        return {
          currentBranch: mockDefaultBranch,
        };
      },
    });
  };

  const findDropdown = () => wrapper.findComponent(GlDropdown);
  const findDropdownItems = () => wrapper.findAll(GlDropdownItem);

  beforeEach(() => {
    mockAvailableBranchQuery = jest.fn();
  });

  afterEach(() => {
    mockAvailableBranchQuery.mockReset();

    wrapper.destroy();
    wrapper = null;
  });

  describe('while querying', () => {
    beforeEach(() => {
      createComponentWithApollo();
    });

    it('does not render dropdown', () => {
      expect(findDropdown().exists()).toBe(false);
    });
  });

  describe('after querying', () => {
    beforeEach(async () => {
      mockAvailableBranchQuery.mockResolvedValue(mockProjectBranches);
      createComponentWithApollo();
      await waitForPromises();
    });

    it('query is called with correct variables', async () => {
      expect(mockAvailableBranchQuery).toHaveBeenCalledTimes(1);
      expect(mockAvailableBranchQuery).toHaveBeenCalledWith(
        expect.anything(),
        {
          fullPath: mockProjectFullPath,
        },
        expect.anything(),
        expect.anything(),
      );
    });

    it('renders list of branches', () => {
      expect(findDropdown().exists()).toBe(true);
      expect(findDropdownItems()).toHaveLength(5);
    });

    it('renders current branch at the top of the list with a check mark', () => {
      const firstDropdownItem = findDropdownItems().at(0);
      const icon = firstDropdownItem.findComponent(GlIcon);

      expect(firstDropdownItem.text()).toBe(mockDefaultBranch);
      expect(icon.exists()).toBe(true);
      expect(icon.props('name')).toBe('check');
    });

    it('does not render check mark for other branches', () => {
      const secondDropdownItem = findDropdownItems().at(1);
      const icon = secondDropdownItem.findComponent(GlIcon);

      expect(icon.classes()).toContain('gl-visibility-hidden');
    });
  });
});

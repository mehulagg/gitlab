import { GlDropdown, GlDropdownItem, GlSearchBoxByType } from '@gitlab/ui';
import { shallowMount, mount } from '@vue/test-utils';
import { nextTick } from 'vue';
import Api from 'ee/api';
import BranchesSelect from 'ee/status_checks/components/branches_select.vue';
import waitForPromises from 'helpers/wait_for_promises';
import { TEST_BRANCHES_SELECTIONS, TEST_PROJECT_ID, TEST_PROTECTED_BRANCHES } from '../mock_data';

const branchNames = () => TEST_BRANCHES_SELECTIONS.map((branch) => branch.name);
const protectedBranchNames = () => TEST_PROTECTED_BRANCHES.map((branch) => branch.name);

describe('Branches Select', () => {
  let wrapper;

  const findDropdown = () => wrapper.findComponent(GlDropdown);
  const findDropdownItems = () => wrapper.findAllComponents(GlDropdownItem);
  const findSearch = () => wrapper.findComponent(GlSearchBoxByType);

  const createComponent = (props = {}, mountFn = shallowMount) => {
    wrapper = mountFn(BranchesSelect, {
      propsData: {
        projectId: '1',
        ...props,
      },
      attachTo: document.body,
    });
  };

  beforeEach(() => {
    jest
      .spyOn(Api, 'projectProtectedBranches')
      .mockReturnValue(Promise.resolve(TEST_PROTECTED_BRANCHES));
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders dropdown', async () => {
    createComponent();
    await waitForPromises();

    expect(findDropdown().exists()).toBe(true);
  });

  it('renders dropdown with invalid class if is invalid', async () => {
    createComponent({ isInvalid: true });
    await waitForPromises();

    expect(findDropdown().classes('is-invalid')).toBe(true);
  });

  it('sets the initially selected item', async () => {
    createComponent(
      {
        selectedBranches: [
          {
            id: 1,
            name: 'main',
          },
        ],
      },
      mount,
    );
    await waitForPromises();

    expect(findDropdown().props('text')).toBe('main');
    expect(
      findDropdownItems()
        .filter((item) => item.text() === 'main')
        .at(0)
        .props('isChecked'),
    ).toBe(true);
  });

  it('displays all the protected branches and any branch', async () => {
    createComponent();
    await nextTick();
    expect(findDropdown().props('loading')).toBe(true);
    await waitForPromises();

    expect(findDropdownItems()).toHaveLength(branchNames().length);
    expect(findDropdown().props('loading')).toBe(false);
  });

  describe('with search term', () => {
    beforeEach(() => {
      createComponent({}, mount);
      return waitForPromises();
    });

    it('fetches protected branches with search term', async () => {
      const term = 'lorem';

      findSearch().vm.$emit('input', term);
      await nextTick();
      expect(findSearch().props('isLoading')).toBe(true);
      await waitForPromises();

      expect(Api.projectProtectedBranches).toHaveBeenCalledWith(TEST_PROJECT_ID, term);
      expect(findSearch().props('isLoading')).toBe(false);
    });

    it('fetches protected branches with no any branch if there is a search', async () => {
      findSearch().vm.$emit('input', 'main');
      await waitForPromises();

      expect(findDropdownItems()).toHaveLength(protectedBranchNames().length);
    });

    it('fetches protected branches with any branch if search contains term "any"', async () => {
      findSearch().vm.$emit('input', 'any');
      await waitForPromises();

      expect(findDropdownItems()).toHaveLength(branchNames().length);
    });
  });

  it('when the branch is changed it sets the isChecked property and emits the input event', async () => {
    createComponent({}, mount);
    await waitForPromises();
    await findDropdownItems().at(1).vm.$emit('click');

    expect(findDropdownItems().at(1).props('isChecked')).toBe(true);
    expect(wrapper.emitted().input).toStrictEqual([[1]]);
  });
});

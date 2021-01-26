import { shallowMount, createLocalVue } from '@vue/test-utils';
import $ from 'jquery';
import Vuex from 'vuex';
import waitForPromises from 'helpers/wait_for_promises';
import Api from 'ee/api';
import BranchesSelect from 'ee/approvals/components/branches_select.vue';

const TEST_DEFAULT_BRANCH = { name: 'Any branch' };
const TEST_PROJECT_ID = '1';
const TEST_PROTECTED_BRANCHES = [
  { id: 1, name: 'master' },
  { id: 2, name: 'development' },
];
const TEST_BRANCHES_SELECTIONS = [TEST_DEFAULT_BRANCH, ...TEST_PROTECTED_BRANCHES];
const waitForEvent = ($input, event) => new Promise((resolve) => $input.one(event, resolve));
const select2Container = () => document.querySelector('.select2-container');
const select2DropdownOptions = () => document.querySelectorAll('.result-name');
const branchNames = () => TEST_BRANCHES_SELECTIONS.map((branch) => branch.name);
const protectedBranchNames = () => TEST_PROTECTED_BRANCHES.map((branch) => branch.name);
const localVue = createLocalVue();

localVue.use(Vuex);

describe('Branches Select', () => {
  let wrapper;
  let store;
  let $input;

  const createComponent = async (props = {}) => {
    wrapper = shallowMount(localVue.extend(BranchesSelect), {
      propsData: {
        projectId: '1',
        ...props,
      },
      localVue,
      store: new Vuex.Store(store),
      attachTo: document.body,
    });

    await waitForPromises();

    $input = $(wrapper.vm.$refs.input);
  };

  const search = (term = '') => {
    $input.select2('search', term);
  };

  beforeEach(() => {
    jest
      .spyOn(Api, 'projectProtectedBranches')
      .mockReturnValue(Promise.resolve(TEST_PROTECTED_BRANCHES));
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders select2 input', async () => {
    expect(select2Container()).toBe(null);

    await createComponent();

    expect(select2Container()).not.toBe(null);
  });

  it('displays all the protected branches and any branch', async (done) => {
    await createComponent();
    waitForEvent($input, 'select2-loaded')
      .then(() => {
        const nodeList = select2DropdownOptions();
        const names = [...nodeList].map((el) => el.textContent);

        expect(names).toEqual(branchNames());
      })
      .then(done)
      .catch(done.fail);
    search();
  });

  describe('with search term', () => {
    beforeEach(() => {
      return createComponent();
    });

    it('fetches protected branches with search term', (done) => {
      const term = 'lorem';
      waitForEvent($input, 'select2-loaded')
        .then(() => {})
        .then(done)
        .catch(done.fail);

      search(term);

      expect(Api.projectProtectedBranches).toHaveBeenCalledWith(TEST_PROJECT_ID, term);
    });

    it('fetches protected branches with no any branch if there is search', (done) => {
      waitForEvent($input, 'select2-loaded')
        .then(() => {
          const nodeList = select2DropdownOptions();
          const names = [...nodeList].map((el) => el.textContent);

          expect(names).toEqual(protectedBranchNames());
        })
        .then(done)
        .catch(done.fail);
      search('master');
    });

    it('fetches protected branches with any branch if search contains term "any"', (done) => {
      waitForEvent($input, 'select2-loaded')
        .then(() => {
          const nodeList = select2DropdownOptions();
          const names = [...nodeList].map((el) => el.textContent);

          expect(names).toEqual(branchNames());
        })
        .then(done)
        .catch(done.fail);
      search('any');
    });
  });

  it('emits input when data changes', async (done) => {
    await createComponent();

    const selectedIndex = 1;
    const selectedId = TEST_BRANCHES_SELECTIONS[selectedIndex].id;
    const expected = [[selectedId]];

    waitForEvent($input, 'select2-loaded')
      .then(() => {
        const options = select2DropdownOptions();
        $(options[selectedIndex]).trigger('mouseup');
      })
      .then(done)
      .catch(done.fail);

    waitForEvent($input, 'change')
      .then(() => {
        expect(wrapper.emitted().input).toEqual(expected);
      })
      .then(done)
      .catch(done.fail);

    search();
  });
});

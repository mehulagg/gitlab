import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import $ from 'jquery';
import BranchesSelect from 'ee/approvals/components/branches_select.vue';
import { createStoreOptions } from 'ee/approvals/stores';
import ProjectSettingsModule from 'ee/approvals/stores/modules/project_settings';

const TEST_DEFAULT_BRANCH = { name: 'Any branch' };
const TEST_PROTECTED_BRANCHES = [{ id: 1, name: 'master' }, { id: 2, name: 'master2' }];
const TEST_BRANCHES_SELECTIONS = [TEST_DEFAULT_BRANCH, ...TEST_PROTECTED_BRANCHES];
const DEBOUNCE_TIME = 250;
const waitForEvent = ($input, event) => new Promise(resolve => $input.one(event, resolve));
const select2Container = () => document.querySelector('.select2-container');
const select2DropdownOptions = () => document.querySelectorAll('.result-name');
const branchNames = () => TEST_BRANCHES_SELECTIONS.map(branch => branch.name);
const localVue = createLocalVue();

localVue.use(Vuex);

describe('Branches Select', () => {
  let wrapper;
  let store;
  let $input;

  const createComponent = (props = {}) => {
    wrapper = mount(localVue.extend(BranchesSelect), {
      propsData: {
        projectId: '1',
        ...props,
      },
      localVue,
      store: new Vuex.Store(store),
      attachToDocument: true,
    });

    $input = $(wrapper.vm.$refs.input);
  };

  const search = () => {
    $input.select2('search');
    jasmine.clock().tick(DEBOUNCE_TIME);
  };

  beforeEach(() => {
    store = createStoreOptions(ProjectSettingsModule());
    store.state.settings.protectedBranches = TEST_PROTECTED_BRANCHES;
    jasmine.clock().install();
  });

  afterEach(() => {
    jasmine.clock().uninstall();
    wrapper.destroy();
  });

  it('renders select2 input', () => {
    expect(select2Container()).toBe(null);

    createComponent();

    expect(select2Container()).not.toBe(null);
  });

  it('displays all the protected branches', done => {
    createComponent();
    waitForEvent($input, 'select2-loaded')
      .then(() => {
        const nodeList = select2DropdownOptions();
        const names = [...nodeList].map(el => el.textContent);

        expect(names).toEqual(branchNames());
      })
      .then(done)
      .catch(done.fail);
    search();
  });

  it('emits input when data changes', done => {
    createComponent();

    const selectedIndex = 1;
    const selectedId = TEST_BRANCHES_SELECTIONS[selectedIndex].id;
    const expected = [
      {
        name: 'input',
        args: [selectedId],
      },
    ];

    waitForEvent($input, 'select2-loaded')
      .then(() => {
        const options = select2DropdownOptions();
        $(options[selectedIndex]).trigger('mouseup');
      })
      .then(done)
      .catch(done.fail);

    waitForEvent($input, 'change')
      .then(() => {
        expect(wrapper.emittedByOrder()).toEqual(expected);
      })
      .then(done)
      .catch(done.fail);

    search();
  });
});

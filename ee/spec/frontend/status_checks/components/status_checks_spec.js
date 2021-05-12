import { GlTable } from '@gitlab/ui';
import { mount, shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import Vuex from 'vuex';
import Actions from 'ee/status_checks/components/actions.vue';
import Branch from 'ee/status_checks/components/branch.vue';
import ModalCreate from 'ee/status_checks/components/modal_create.vue';
import StatusChecks, { i18n } from 'ee/status_checks/components/status_checks.vue';
import createStore from 'ee/status_checks/store';
import { SET_STATUS_CHECKS } from 'ee/status_checks/store/mutation_types';

Vue.use(Vuex);

describe('Status checks', () => {
  let store;
  let wrapper;

  const createWrapper = (mountFn = mount) => {
    store = createStore();
    wrapper = mountFn(StatusChecks, { store });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findCreateModal = () => wrapper.findComponent(ModalCreate);
  const findTable = () => wrapper.findComponent(GlTable);
  const findHeaders = () => findTable().find('thead').find('tr').findAll('th');
  const findBranch = (trIdx) => wrapper.findAllComponents(Branch).at(trIdx);
  const findActions = (trIdx) => wrapper.findAllComponents(Actions).at(trIdx);
  const findCell = (trIdx, tdIdx) => {
    return findTable().find('tbody').findAll('tr').at(trIdx).findAll('td').at(tdIdx);
  };

  describe('Initially', () => {
    it('renders the table', () => {
      createWrapper(shallowMount);

      expect(findTable().exists()).toBe(true);
    });

    it('renders the empty state when no status checks exist', () => {
      createWrapper();

      expect(findCell(0, 0).text()).toBe(i18n.emptyTableText);
    });

    it('renders the create modal', () => {
      createWrapper(shallowMount);

      expect(findCreateModal().exists()).toBe(true);
    });
  });

  describe('Filled table', () => {
    const statusChecks = [
      { name: 'Foo', externalUrl: 'http://foo.com/api', protectedBranches: [] },
      { name: 'Bar', externalUrl: 'http://bar.com/api', protectedBranches: [{ name: 'main' }] },
    ];

    beforeEach(() => {
      createWrapper();
      store.commit(SET_STATUS_CHECKS, statusChecks);
    });

    it('renders the headers', () => {
      expect(findHeaders()).toHaveLength(4);
      expect(findHeaders().at(0).text()).toBe(i18n.nameHeader);
      expect(findHeaders().at(1).text()).toBe(i18n.apiHeader);
      expect(findHeaders().at(2).text()).toBe(i18n.branchHeader);
      expect(findHeaders().at(3).text()).toBe('');
    });

    describe.each(statusChecks)('status check %#', (statusCheck) => {
      const index = statusChecks.indexOf(statusCheck);

      it('renders the name', () => {
        expect(findCell(index, 0).text()).toBe(statusCheck.name);
      });

      it('renders the URL', () => {
        expect(findCell(index, 1).text()).toBe(statusCheck.externalUrl);
      });

      it('renders the branch', () => {
        expect(findBranch(index, 1).props('branches')).toBe(statusCheck.protectedBranches);
      });

      it('renders the actions', () => {
        expect(findActions(index, 1).props('statusCheck')).toStrictEqual(statusCheck);
      });
    });
  });
});

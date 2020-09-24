import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlEmptyState, GlFormCheckbox } from '@gitlab/ui';

import SecurityDashboardTable from 'ee/security_dashboard/components/security_dashboard_table.vue';
import SecurityDashboardTableRow from 'ee/security_dashboard/components/security_dashboard_table_row.vue';
import SelectionSummary from 'ee/security_dashboard/components/selection_summary.vue';
import createStore from 'ee/security_dashboard/store';

import {
  RECEIVE_VULNERABILITIES_ERROR,
  RECEIVE_VULNERABILITIES_SUCCESS,
  REQUEST_VULNERABILITIES,
} from 'ee/security_dashboard/store/modules/vulnerabilities/mutation_types';

import mockDataVulnerabilities from '../store/modules/vulnerabilities/data/mock_data_vulnerabilities';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Security Dashboard Table', () => {
  const vulnerabilitiesEndpoint = '/vulnerabilitiesEndpoint.json';
  let store;
  let wrapper;

  beforeEach(() => {
    store = createStore();
    wrapper = shallowMount(SecurityDashboardTable, {
      localVue,
      store,
    });
    store.state.vulnerabilities.vulnerabilitiesEndpoint = vulnerabilitiesEndpoint;
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findCheckbox = () => wrapper.find(GlFormCheckbox);

  describe('while loading', () => {
    beforeEach(() => {
      store.commit(`vulnerabilities/${REQUEST_VULNERABILITIES}`);
    });

    it('should render 10 skeleton rows in the table', () => {
      expect(wrapper.findAll(SecurityDashboardTableRow)).toHaveLength(10);
    });
  });

  describe('with a list of vulnerabilities', () => {
    beforeEach(() => {
      store.commit(`vulnerabilities/${RECEIVE_VULNERABILITIES_SUCCESS}`, {
        vulnerabilities: mockDataVulnerabilities,
        pageInfo: {},
      });
    });

    it('should render a row for each vulnerability', () => {
      expect(wrapper.findAll(SecurityDashboardTableRow)).toHaveLength(
        mockDataVulnerabilities.length,
      );
    });

    it('should not show the multi select box', () => {
      expect(wrapper.find(SelectionSummary).exists()).toBe(false);
    });

    it('should show the select all as unchecked', () => {
      expect(findCheckbox().attributes('checked')).toBeFalsy();
    });

    describe('with vulnerabilities selected', () => {
      beforeEach(() => {
        findCheckbox().vm.$emit('change');
      });

      it('should show the multi select box', () => {
        expect(wrapper.find(SelectionSummary).exists()).toBe(true);
      });

      it('should show the select all as checked', () => {
        expect(findCheckbox().attributes('checked')).toBe('true');
      });
    });
  });

  describe('with no vulnerabilties', () => {
    beforeEach(() => {
      store.commit(`vulnerabilities/${RECEIVE_VULNERABILITIES_SUCCESS}`, {
        vulnerabilities: [],
        pageInfo: {},
      });
    });

    it('should render the empty state', () => {
      expect(wrapper.find(GlEmptyState).exists()).toBe(true);
    });
  });

  describe('on error', () => {
    beforeEach(() => {
      store.commit(`vulnerabilities/${RECEIVE_VULNERABILITIES_ERROR}`);
    });

    it('should not render the empty state', () => {
      expect(wrapper.find(GlEmptyState).exists()).toBe(false);
    });

    it('should render the error alert', () => {
      expect(wrapper.find('.flash-alert').exists()).toBe(true);
    });
  });

  describe('with a custom empty state', () => {
    beforeEach(() => {
      wrapper = shallowMount(SecurityDashboardTable, {
        localVue,
        store,
        slots: {
          emptyState: '<div class="customEmptyState">Hello World</div>',
        },
      });

      store.commit(`vulnerabilities/${RECEIVE_VULNERABILITIES_SUCCESS}`, {
        vulnerabilities: [],
        pageInfo: {},
      });
    });

    it('should render the custom empty state', () => {
      expect(wrapper.find('.customEmptyState').exists()).toBe(true);
    });
  });
});

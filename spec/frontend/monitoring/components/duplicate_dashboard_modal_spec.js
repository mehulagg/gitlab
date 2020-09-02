import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import { GlAlert, GlLoadingIcon, GlModal } from '@gitlab/ui';

import waitForPromises from 'helpers/wait_for_promises';

import { monitoringDashboard } from '~/monitoring/stores';
import DuplicateDashboardModal from '~/monitoring/components/duplicate_dashboard_modal.vue';
import DuplicateDashboardForm from '~/monitoring/components/duplicate_dashboard_form.vue';

import { dashboardGitResponse } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('duplicate dashboard modal', () => {
  let wrapper;
  const duplicateSystemDashboardAction = jest.fn().mockResolvedValue();
  let okEvent;

  function createComponent({ getters = {}, state: initialState } = {}) {
    const fakeStore = new Vuex.Store({
      modules: {
        monitoringDashboard: {
          ...monitoringDashboard,
          actions: { duplicateSystemDashboard: duplicateSystemDashboardAction },
          getters: { ...monitoringDashboard.getters, ...getters },
          state: { ...monitoringDashboard.state(), ...initialState },
        },
      },
    });

    return shallowMount(DuplicateDashboardModal, {
      store: fakeStore,
      propsData: {
        defaultBranch: 'master',
        modalId: 'id',
      },
    });
  }

  const findAlert = () => wrapper.find(GlAlert);
  const findModal = () => wrapper.find(GlModal);
  const findDuplicateDashboardForm = () => wrapper.find(DuplicateDashboardForm);

  beforeEach(() => {
    okEvent = {
      preventDefault: jest.fn(),
    };

    wrapper = createComponent({
      state: { dashboards: dashboardGitResponse },
      getters: { selectedDashboard: () => dashboardGitResponse[0] },
    });

    wrapper.vm.$refs.duplicateDashboardModal.hide = jest.fn();
  });

  it('contains a form to duplicate a dashboard', () => {
    expect(findDuplicateDashboardForm().exists()).toBe(true);
  });

  it('saves a new dashboard', () => {
    findModal().vm.$emit('ok', okEvent);

    return waitForPromises().then(() => {
      expect(okEvent.preventDefault).toHaveBeenCalled();
      expect(wrapper.emitted().dashboardDuplicated).toBeTruthy();
      expect(wrapper.emitted().dashboardDuplicated[0]).toEqual([dashboardGitResponse[0]]);
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      expect(wrapper.vm.$refs.duplicateDashboardModal.hide).toHaveBeenCalled();
      expect(findAlert().exists()).toBe(false);
    });
  });

  it('handles error when a new dashboard is not saved', () => {
    const errMsg = 'An error occurred';

    duplicateSystemDashboardAction.mockRejectedValueOnce(errMsg);
    findModal().vm.$emit('ok', okEvent);

    return waitForPromises().then(() => {
      expect(okEvent.preventDefault).toHaveBeenCalled();

      expect(findAlert().exists()).toBe(true);
      expect(findAlert().text()).toBe(errMsg);

      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      expect(wrapper.vm.$refs.duplicateDashboardModal.hide).not.toHaveBeenCalled();
    });
  });

  it('updates the form on changes', () => {
    const formVals = {
      dashboard: 'common_metrics.yml',
      commitMessage: 'A commit message',
    };

    findModal()
      .find(DuplicateDashboardForm)
      .vm.$emit('change', formVals);

    // Binding's second argument contains the modal id
    expect(wrapper.vm.form).toEqual(formVals);
  });
});

import Vue from 'vue';
import Vuex from 'vuex';
import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { VULNERABILITY_MODAL_ID } from 'ee/vue_shared/security_reports/components/constants';
import component from 'ee/reports/components/modal_open_name.vue';
import { BV_SHOW_MODAL } from '~/lib/utils/constants';

Vue.use(Vuex);

describe('Modal open name', () => {
  const Component = Vue.extend(component);
  let vm;

  const store = new Vuex.Store({
    actions: {
      setModalData: () => {},
    },
    state: {},
    mutations: {},
  });

  beforeEach(() => {
    vm = mountComponentWithStore(Component, {
      store,
      props: {
        issue: {
          title: 'Issue',
        },
        status: 'failed',
      },
    });
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('renders the issue name', () => {
    expect(vm.$el.textContent.trim()).toEqual('Issue');
  });

  it('calls setModalData actions and opens modal when button is clicked', () => {
    jest.spyOn(vm, 'setModalData').mockImplementation(() => {});
    jest.spyOn(vm.$root, '$emit');

    vm.$el.click();

    expect(vm.setModalData).toHaveBeenCalled();
    expect(vm.$root.$emit).toHaveBeenCalledWith(BV_SHOW_MODAL, VULNERABILITY_MODAL_ID);
  });
});

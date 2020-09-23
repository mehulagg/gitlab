import Vue from 'vue';
import sidebarWeight from 'ee/sidebar/components/weight/sidebar_weight.vue';
import SidebarMediator from 'ee/sidebar/sidebar_mediator';
import SidebarStore from 'ee/sidebar/stores/sidebar_store';
import mountComponent from 'helpers/vue_mount_component_helper';
import SidebarService from '~/sidebar/services/sidebar_service';
import eventHub from '~/sidebar/event_hub';
import Mock from './ee_mock_data';

describe('Sidebar Weight', () => {
  let vm;
  let sidebarMediator;
  let SidebarWeight;

  beforeEach(() => {
    SidebarWeight = Vue.extend(sidebarWeight);
    // Set up the stores, services, etc
    sidebarMediator = new SidebarMediator(Mock.mediator);
  });

  afterEach(() => {
    vm.$destroy();
    SidebarService.singleton = null;
    SidebarStore.singleton = null;
    SidebarMediator.singleton = null;
  });

  it('calls the mediator updateWeight on event', () => {
    jest.spyOn(SidebarMediator.prototype, 'updateWeight').mockReturnValue(Promise.resolve());
    vm = mountComponent(SidebarWeight, {
      mediator: sidebarMediator,
    });

    eventHub.$emit('updateWeight');

    expect(SidebarMediator.prototype.updateWeight).toHaveBeenCalled();
  });
});

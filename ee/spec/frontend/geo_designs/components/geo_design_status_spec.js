import Vuex from 'vuex';
import { createLocalVue, mount } from '@vue/test-utils';
import store from 'ee/geo_designs/store';
import GeoDesignStatus from 'ee/geo_designs/components/geo_design_status.vue';
import {
  FILTER_STATES,
  STATUS_ICON_NAMES,
  STATUS_ICON_CLASS,
  DEFAULT_STATUS,
} from 'ee/geo_designs/store/constants';
import Icon from '~/vue_shared/components/icon.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoDesignStatus', () => {
  let wrapper;

  const propsData = {
    status: FILTER_STATES.SYNCED,
  };

  const createComponent = () => {
    wrapper = mount(localVue.extend(GeoDesignStatus), {
      sync: false,
      localVue,
      store,
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoDesignStatusContainer = () => wrapper.find('div');
  const findIcon = () => findGeoDesignStatusContainer().find(Icon);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders status container', () => {
      expect(findGeoDesignStatusContainer().exists()).toBe(true);
    });
  });

  describe.each`
    status                   | iconName                                    | iconClass
    ${FILTER_STATES.SYNCED}  | ${STATUS_ICON_NAMES[FILTER_STATES.SYNCED]}  | ${STATUS_ICON_CLASS[FILTER_STATES.SYNCED]}
    ${FILTER_STATES.PENDING} | ${STATUS_ICON_NAMES[FILTER_STATES.PENDING]} | ${STATUS_ICON_CLASS[FILTER_STATES.PENDING]}
    ${FILTER_STATES.FAILED}  | ${STATUS_ICON_NAMES[FILTER_STATES.FAILED]}  | ${STATUS_ICON_CLASS[FILTER_STATES.FAILED]}
    ${DEFAULT_STATUS}        | ${STATUS_ICON_NAMES[DEFAULT_STATUS]}        | ${STATUS_ICON_CLASS[DEFAULT_STATUS]}
  `(`iconProperties`, ({ status, iconName, iconClass }) => {
    beforeEach(() => {
      propsData.status = status;
      createComponent();
    });

    describe(`with filter set to ${status}`, () => {
      beforeEach(() => {
        wrapper.vm.icon = wrapper.vm.iconProperties();
      });

      it(`sets icon.name to ${iconName}`, () => {
        expect(wrapper.vm.icon.name).toEqual(iconName);
      });

      it(`sets icon.cssClass to ${iconClass}`, () => {
        expect(wrapper.vm.icon.cssClass).toEqual(iconClass);
      });

      it(`sets svg to ic-${iconName}`, () => {
        expect(findIcon().classes()).toContain(`ic-${wrapper.vm.icon.name}`);
      });
    });
  });
});

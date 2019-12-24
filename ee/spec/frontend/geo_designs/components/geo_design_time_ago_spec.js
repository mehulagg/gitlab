import Vuex from 'vuex';
import { createLocalVue, mount } from '@vue/test-utils';
import store from 'ee/geo_designs/store';
import GeoDesignTimeAgo from 'ee/geo_designs/components/geo_design_time_ago.vue';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoDesignTimeAgo', () => {
  let wrapper;

  const propsData = {
    label: 'Test Label',
    dateString: '09-23-1994',
    defaultText: 'Default Text',
  };

  const createComponent = () => {
    wrapper = mount(localVue.extend(GeoDesignTimeAgo), {
      sync: false,
      localVue,
      store,
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoDesignTimeAgo = () => wrapper.find(GeoDesignTimeAgo);
  const findTimeAgo = () => findGeoDesignTimeAgo().find(TimeAgo);
  const findDefaultText = () => findGeoDesignTimeAgo().find('span');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders GeoDesignTimeAgo container', () => {
      expect(findGeoDesignTimeAgo().exists()).toBe(true);
    });

    describe('when dateString exists', () => {
      describe('TimeAgo', () => {
        it('renders', () => {
          expect(findTimeAgo().exists()).toBe(true);
        });

        it('sets time prop', () => {
          expect(findTimeAgo().props().time).toBe(propsData.dateString);
        });

        it(`sets innerHTML as ${propsData.dateString}`, () => {
          expect(findTimeAgo().html()).toMatchSnapshot();
        });
      });

      it('hides DefaultText', () => {
        expect(findDefaultText().exists()).toBe(false);
      });
    });

    describe('when dateString is null', () => {
      beforeEach(() => {
        propsData.dateString = null;
        createComponent();
      });

      it('hides TimeAgo', () => {
        expect(findTimeAgo().exists()).toBe(false);
      });

      describe('DefaultText', () => {
        it('renders', () => {
          expect(findDefaultText().exists()).toBe(true);
        });

        it('sets innerHTML as props.defaultText', () => {
          expect(findDefaultText().html()).toMatchSnapshot();
        });
      });
    });
  });
});

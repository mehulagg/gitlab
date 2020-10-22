import { GlPath, GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import Component from 'ee/analytics/cycle_analytics/components/path_navigation.vue';
import { transformedStagePathData, issueStage } from '../mock_data';

describe('PathNavigation', () => {
  let wrapper = null;

  const createComponent = props => {
    return mount(Component, {
      propsData: {
        stages: transformedStagePathData,
        selectedStage: issueStage,
        loading: false,
        ...props,
      },
    });
  };

  const pathNavigationItems = () => {
    return wrapper.findAll('.gl-path-button');
  };

  const clickItemAt = index => {
    pathNavigationItems()
      .at(index)
      .trigger('click');
  };

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('displays correctly', () => {
    it('has the correct props', () => {
      expect(wrapper.find(GlPath).props('items')).toMatchObject(transformedStagePathData);
    });

    it('contains all the expected stages', () => {
      const html = wrapper.find(GlPath).html();

      transformedStagePathData.forEach(stage => {
        expect(html).toContain(stage.title);
      });
    });

    describe('loading', () => {
      describe('is false', () => {
        it('displays the gl-path component', () => {
          expect(wrapper.find(GlPath).exists()).toBe(true);
        });

        it('hides the gl-skeleton-loading component', () => {
          expect(wrapper.find(GlSkeletonLoading).exists()).toBe(false);
        });
      });

      describe('is true', () => {
        beforeEach(() => {
          wrapper = createComponent({ loading: true });
        });

        it('hides the gl-path component', () => {
          expect(wrapper.find(GlPath).exists()).toBe(false);
        });

        it('displays the gl-skeleton-loading component', () => {
          expect(wrapper.find(GlSkeletonLoading).exists()).toBe(true);
        });
      });
    });
  });

  describe('event handling', () => {
    it('emits the selected event', () => {
      expect(wrapper.emitted('selected')).toBeUndefined();

      clickItemAt(0);
      clickItemAt(1);
      clickItemAt(2);

      expect(wrapper.emitted().selected).toEqual([
        [transformedStagePathData[0]],
        [transformedStagePathData[1]],
        [transformedStagePathData[2]],
      ]);
    });
  });
});

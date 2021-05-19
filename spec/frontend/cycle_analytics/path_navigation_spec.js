import { GlPath, GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import Component from '~/cycle_analytics/components/path_navigation.vue';
import { transformedProjectStagePathData, selectedStage } from './mock_data';

describe('Project PathNavigation', () => {
  let wrapper = null;

  const createComponent = (props) => {
    return mount(Component, {
      propsData: {
        stages: transformedProjectStagePathData,
        selectedStage,
        loading: false,
        ...props,
      },
    });
  };

  const pathNavigationTitles = () => {
    return wrapper.findAll('.gl-path-button');
  };

  const pathNavigationItems = () => {
    return wrapper.findAll('.gl-path-nav-list-item');
  };

  const clickItemAt = (index) => {
    pathNavigationTitles().at(index).trigger('click');
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
      expect(wrapper.find(GlPath).props('items')).toMatchObject(transformedProjectStagePathData);
    });

    it('contains all the expected stages', () => {
      const html = wrapper.find(GlPath).html();

      transformedProjectStagePathData.forEach((stage) => {
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

        // TODO: make this test more granular
        it('matches the snapshot', () => {
          expect(wrapper.element).toMatchSnapshot();
        });

        describe('popovers', () => {
          beforeEach(() => {
            wrapper = createComponent({ stages: transformedProjectStagePathData });
          });

          it('renders popovers for all stages', () => {
            const pathItemContent = pathNavigationItems().wrappers;

            pathItemContent.forEach((stage) => {
              expect(stage.find('[data-testid="stage-item-popover"]').exists()).toBe(true);
            });
          });

          it('shows the median stage time for the first stage item', () => {
            const firstPopover = wrapper.findAll('[data-testid="stage-item-popover"]').at(0);
            expect(firstPopover.text()).toContain('Stage time (median)');
          });
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
        [transformedProjectStagePathData[0]],
        [transformedProjectStagePathData[1]],
        [transformedProjectStagePathData[2]],
      ]);
    });
  });
});

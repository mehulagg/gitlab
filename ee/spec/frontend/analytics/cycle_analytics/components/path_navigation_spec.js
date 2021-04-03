import { GlPath, GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import Component from 'ee/analytics/cycle_analytics/components/path_navigation.vue';
import { transformedStagePathData, issueStage } from '../mock_data';

describe('PathNavigation', () => {
  let wrapper = null;

  const createComponent = (props) => {
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

  const clickItemAt = (index) => {
    pathNavigationItems().at(index).trigger('click');
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

      transformedStagePathData.forEach((stage) => {
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

        it('matches the snapshot', () => {
          expect(wrapper.element).toMatchSnapshot();
        });

        describe('popovers', () => {
          const modifiedStages = [
            ...transformedStagePathData.slice(0, 3),
            {
              ...transformedStagePathData[3],
              startEventHtmlDescription: null,
              endEventHtmlDescription: null,
            },
          ];

          beforeEach(() => {
            wrapper = createComponent({ stages: modifiedStages });
          });

          it('renders popovers only for stages with either a start event and/or and end event', () => {
            expect(wrapper.findAll('[data-testid="stage-item-popover"]')).toHaveLength(2);
          });

          it('shows the sanitized start event description for the first stage item', () => {
            const firstPopover = wrapper.findAll('[data-testid="stage-item-popover"]').at(0);
            const expectedStartEventDescription = 'Issue created';
            expect(firstPopover.text()).toContain(expectedStartEventDescription);
          });

          it('shows the sanitized end event description for the first stage item', () => {
            const firstPopover = wrapper.findAll('[data-testid="stage-item-popover"]').at(0);
            const expectedStartEventDescription =
              'Issue first associated with a milestone or issue first added to a board';
            expect(firstPopover.text()).toContain(expectedStartEventDescription);
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
        [transformedStagePathData[0]],
        [transformedStagePathData[1]],
        [transformedStagePathData[2]],
      ]);
    });
  });
});

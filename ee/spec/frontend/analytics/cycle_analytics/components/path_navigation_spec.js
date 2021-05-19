import { mount } from '@vue/test-utils';
import Component from '~/cycle_analytics/components/path_navigation.vue';
import { transformedStagePathData, issueStage } from '../mock_data';

describe('Group PathNavigation', () => {
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
    return wrapper.findAll('.gl-path-nav-list-item');
  };

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('popovers', () => {
    beforeEach(() => {
      wrapper = createComponent({ stages: transformedStagePathData });
    });

    it('renders popovers for all stages except for the overview stage', () => {
      const pathItemContent = pathNavigationItems().wrappers;
      const [overviewStage, ...popoverStages] = pathItemContent;

      expect(overviewStage.text()).toContain('Overview');
      expect(overviewStage.find('[data-testid="stage-item-popover"]').exists()).toBe(false);

      popoverStages.forEach((stage) => {
        expect(stage.find('[data-testid="stage-item-popover"]').exists()).toBe(true);
      });
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

    it('shows the median stage time for the first stage item', () => {
      const firstPopover = wrapper.findAll('[data-testid="stage-item-popover"]').at(0);
      expect(firstPopover.text()).toContain('Stage time (median)');
    });
  });
});

import { mount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import Component from '~/cycle_analytics/components/path_navigation.vue';
import { OVERVIEW_STAGE_ID } from '~/cycle_analytics/constants';
import { transformedStagePathData, issueStage } from '../mock_data';

describe('Group PathNavigation', () => {
  let wrapper = null;

  const createComponent = (props) => {
    return extendedWrapper(
      mount(Component, {
        propsData: {
          stages: transformedStagePathData,
          selectedStage: issueStage,
          loading: false,
          ...props,
        },
      }),
    );
  };

  const pathNavigationItems = () => {
    return wrapper.findByTestId('gl-path-nav').findAll('li');
  };

  const pathItemContent = () => pathNavigationItems().wrappers;

  const stagesWithCounts = transformedStagePathData.filter(
    (stage) => stage.id !== OVERVIEW_STAGE_ID,
  );

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
      const [overviewStage, ...popoverStages] = pathItemContent();

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

    it('renders each stage with its stage count', () => {
      const popoverStages = pathItemContent().slice(1); // skip the first stage, the overview does not have a popover
      popoverStages.forEach((stage, index) => {
        const content = stage.find('[data-testid="stage-item-popover"]').html();
        expect(content).toContain('Items in stage');
        expect(content).toContain(`${stagesWithCounts[index].stageCount} items`);
      });
    });
  });
});

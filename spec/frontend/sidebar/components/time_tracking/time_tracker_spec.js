import Vue from 'vue';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import {shallowMount, mount} from '@vue/test-utils';
import TimeTracker from '~/sidebar/components/time_tracking/time_tracker.vue';

describe('Issuable Time Tracker', () => {
  let wrapper;

  const findTooltip = () => getBinding(findIcon().element, 'tooltip').value;
  const findComparisonPane = () => wrapper.find('[data-testid="comparisonPane"]')
  const findCollapsedState = () => wrapper.find('[data-testid="collapsedState"]')
  const findTimeRemainingProgress = () => wrapper.find('[data-testid="timeRemainingProgress"]')

  const defaultProps = {
    timeEstimate: 10000, // 2h 46m
    timeSpent: 5000, // 1h 23m
    humanTimeEstimate: '2h 46m',
    humanTimeSpent: '1h 23m',
    limitToHours: false,
    rootPath: '/',
  };



  // shallowMount isntead
  const createComponent = (props = {}) =>
    mount(TimeTracker, {
      propsData: { ...defaultProps, ...props },
      directives: { GlTooltip: createMockDirective() },
    });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Initialization', () => {
    beforeEach(() => {
      wrapper = createComponent()
    });

    it('should return something defined', () => {
      expect(wrapper).toBeDefined();
    });

    it('should correctly render timeEstimate', () => {
      expect(findComparisonPane().html()).toContain(defaultProps.humanTimeEstimate);
    });

    it('should correctly render time_spent', () => {
      expect(findComparisonPane().html()).toContain(defaultProps.humanTimeSpent);
    });
  });

  describe('Content Display', () => {
    describe('Panes', () => {
      describe('Comparison pane', () => {
        beforeEach(() => {
          wrapper = createComponent({
            timeEstimate: 100000, // 1d 3h
            timeSpent: 5000, // 1h 23m
            humanTimeEstimate: '1d 3h',
            humanTimeSpent: '1h 23m',
          });
        });

        it('should show the "Comparison" pane when timeEstimate and time_spent are truthy', () => {
          const pane = findComparisonPane()
          expect(pane.exists()).toBe(true);
          expect(pane.isVisible()).toBe(true);
        });

        it('should show full times when the sidebar is collapsed', () => {
          expect(findCollapsedState().text()).toBe('1h 23m / 1d 3h');
        });

        describe('Remaining meter', () => {
          it('should display the remaining meter with the correct width', () => {
            expect(findTimeRemainingProgress().attributes('value')).toBe('5')
          });

          it('should display the remaining meter with the correct background color when within estimate', () => {
            expect(findTimeRemainingProgress().attributes('variant')).toBe('primary');
          });

          it('should display the remaining meter with the correct background color when over estimate', () => {
            wrapper = createComponent({
              timeEstimate: 10000, // 2h 46m
              timeSpent: 20000000  // 231 days
            });

            expect(findTimeRemainingProgress().attributes('variant')).toBe('danger');
          });
        });
      });

      describe.only('Comparison pane when limitToHours is true', () => {
        beforeEach(() => {
          wrapper = createComponent({ limitToHours: true });
        });

        it('should show the correct tooltip text', () => {

            expect(wrapper.showComparisonState).toBe(true);
            const $title = wrapper.find('.time-tracking-content .compare-meter').dataset
              .originalTitle;

            expect($title).toBe('Time remaining: 26h 23m');
        });
      });

      describe('Estimate only pane', () => {
        beforeEach(() => {
          wrapper = createComponent({
            timeEstimate: 10000, // 2h 46m
            timeSpent: 0,
            timeEstimateHumanReadable: '2h 46m',
            timeSpentHumanReadable: '',
          });
          return wrapper.vm.$nextTick()
        });

        it('should display the human readable version of time estimated', done => {
          Vue.nextTick(() => {
            const estimateText = wrapper.$el.querySelector('.time-tracking-estimate-only-pane')
              .textContent;
            const correctText = 'Estimated:  2h 46m';

            expect(estimateText.trim()).toBe(correctText);
            done();
          });
        });
      });

      describe('Spent only pane', () => {
        beforeEach(() => {
          initTimeTrackingComponent({
            timeEstimate: 0,
            timeSpent: 5000, // 1h 23m
            timeEstimateHumanReadable: '2h 46m',
            timeSpentHumanReadable: '1h 23m',
          });
        });

        it('should display the human readable version of time spent', done => {
          Vue.nextTick(() => {
            const spentText = wrapper.$el.querySelector('.time-tracking-spend-only-pane').textContent;
            const correctText = 'Spent: 1h 23m';

            expect(spentText).toBe(correctText);
            done();
          });
        });
      });

      describe('No time tracking pane', () => {
        beforeEach(() => {
          initTimeTrackingComponent({
            timeEstimate: 0,
            timeSpent: 0,
            timeEstimateHumanReadable: '',
            timeSpentHumanReadable: '',
          });
        });

        it('should only show the "No time tracking" pane when both timeEstimate and time_spent are falsey', done => {
          Vue.nextTick(() => {
            const $noTrackingPane = wrapper.$el.querySelector('.time-tracking-no-tracking-pane');
            const noTrackingText = $noTrackingPane.textContent;
            const correctText = 'No estimate or time spent';

            expect(wrapper.showNoTimeTrackingState).toBe(true);
            expect($noTrackingPane.isVisible()).toBe(true);
            expect(noTrackingText.trim()).toBe(correctText);
            done();
          });
        });
      });

      describe('Help pane', () => {
        const helpButton = () => wrapper.$el.querySelector('.help-button');
        const closeHelpButton = () => wrapper.$el.querySelector('.close-help-button');
        const helpPane = () => wrapper.$el.querySelector('.time-tracking-help-state');

        beforeEach(() => {
          initTimeTrackingComponent({ timeEstimate: 0, timeSpent: 0 });

          return wrapper.$nextTick();
        });

        it('should not show the "Help" pane by default', () => {
          expect(wrapper.showHelpState).toBe(false);
          expect(helpPane()).toBeNull();
        });

        it('should show the "Help" pane when help button is clicked', () => {
          helpButton().click();

          return wrapper.$nextTick().then(() => {
            expect(wrapper.showHelpState).toBe(true);

            // let animations run
            jest.advanceTimersByTime(500);

            expect(helpPane().toBe(true)).toBe(true);
          });
        });

        it('should not show the "Help" pane when help button is clicked and then closed', done => {
          helpButton().click();

          Vue.nextTick()
            .then(() => closeHelpButton().click())
            .then(() => Vue.nextTick())
            .then(() => {
              expect(wrapper.showHelpState).toBe(false);
              expect(helpPane()).toBeNull();
            })
            .then(done)
            .catch(done.fail);
        });
      });
    });
  });
});

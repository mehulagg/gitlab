import { GlEmptyState, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, mount } from '@vue/test-utils';
import StageTableNew from 'ee/analytics/cycle_analytics/components/stage_table_new.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import {
  stagingEvents,
  stagingStage,
  issueEvents,
  issueStage,
  testEvents,
  testStage,
} from '../mock_data';

let wrapper = null;

const noDataSvgPath = 'path/to/no/data';
const emptyStateMessage = 'Too much data';
const notEnoughDataError = "We don't have enough data to show this stage.";
const [firstIssueEvent] = issueEvents;
const [firstStagingEvent] = stagingEvents;
const [firstTestEvent] = testEvents;

const findStageEvents = () => wrapper.findAllByTestId('vsa-stage-event');
const findStageEventTitle = (ev) => extendedWrapper(ev).findByTestId('vsa-stage-event-title');

function createComponent(props = {}, shallow = false) {
  const func = shallow ? shallowMount : mount;
  return extendedWrapper(
    func(StageTableNew, {
      propsData: {
        isLoading: false,
        stageEvents: issueEvents,
        noDataSvgPath,
        currentStage: issueStage,
        ...props,
      },
      stubs: {
        GlLoadingIcon,
        GlEmptyState,
      },
    }),
  );
}

describe('StageTable', () => {
  afterEach(() => {
    wrapper.destroy();
  });

  describe('is loaded with data', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('will render the correct events', () => {
      const evs = findStageEvents();
      expect(evs).toHaveLength(issueEvents.length);

      const titles = evs.wrappers.map((ev) => findStageEventTitle(ev).text());
      issueEvents.forEach((ev, index) => {
        expect(titles[index]).toBe(ev.title);
      });
    });

    it('will not display the default data message', () => {
      expect(wrapper.html()).not.toContain(notEnoughDataError);
    });
  });

  describe('default event', () => {
    beforeEach(() => {
      wrapper = createComponent({
        stageEvents: [{ ...firstIssueEvent }],
        currentStage: { ...issueStage, custom: false },
      });
    });

    it('will render the event title', () => {
      expect(wrapper.findByTestId('vsa-stage-event-title').text()).toBe(firstIssueEvent.title);
    });

    it('does not render the fork icon', () => {
      expect(wrapper.findByTestId('fork-icon').exists()).toBe(false);
    });

    it('does not render the branch icon', () => {
      expect(wrapper.findByTestId('commit-icon').exists()).toBe(false);
    });

    it('will render the total time', () => {
      expect(wrapper.findByTestId('vsa-stage-event-time').text()).toBe('2 days');
    });

    it('will render the author', () => {
      expect(wrapper.findByTestId('vsa-stage-event-author').text()).toContain(
        firstIssueEvent.author.name,
      );
    });

    it('will render the created at date', () => {
      expect(wrapper.findByTestId('vsa-stage-event-date').text()).toContain(
        firstIssueEvent.createdAt,
      );
    });
  });

  describe('staging event', () => {
    beforeEach(() => {
      wrapper = createComponent({
        stageEvents: [{ ...firstStagingEvent }],
        currentStage: { ...stagingStage, custom: false },
      });
    });

    it('will not render the event title', () => {
      expect(wrapper.findByTestId('vsa-stage-event-title').exists()).toBe(false);
    });

    it('will render the fork icon', () => {
      expect(wrapper.findByTestId('fork-icon').exists()).toBe(true);
    });

    it('will render the branch icon', () => {
      expect(wrapper.findByTestId('commit-icon').exists()).toBe(true);
    });

    it('will render the total time', () => {
      expect(wrapper.findByTestId('vsa-stage-event-time').text()).toBe('2 mins');
    });

    it('will render the build shortSha', () => {
      expect(wrapper.findByTestId('vsa-stage-event-build-sha').text()).toBe(
        firstStagingEvent.shortSha,
      );
    });

    it('will render the author and date', () => {
      const content = wrapper.findByTestId('vsa-stage-event-build-author-and-date').text();
      expect(content).toContain(firstStagingEvent.author.name);
      expect(content).toContain(firstStagingEvent.date);
    });
  });

  describe('test event', () => {
    beforeEach(() => {
      wrapper = createComponent({
        stageEvents: [{ ...firstTestEvent }],
        currentStage: { ...testStage, custom: false },
      });
    });

    it('will not render the event title', () => {
      expect(wrapper.findByTestId('vsa-stage-event-title').exists()).toBe(false);
    });

    it('will render the fork icon', () => {
      expect(wrapper.findByTestId('fork-icon').exists()).toBe(true);
    });

    it('will render the branch icon', () => {
      expect(wrapper.findByTestId('commit-icon').exists()).toBe(true);
    });

    it('will render the total time', () => {
      expect(wrapper.findByTestId('vsa-stage-event-time').text()).toBe('2 mins');
    });

    it('will render the build shortSha', () => {
      expect(wrapper.findByTestId('vsa-stage-event-build-sha').text()).toBe(
        firstTestEvent.shortSha,
      );
    });

    it('will render the build pipeline success icon', () => {
      expect(wrapper.findByTestId('status_success-icon').exists()).toBe(true);
    });

    it('will render the build date', () => {
      const content = wrapper.findByTestId('vsa-stage-event-build-status-date').text();
      expect(content).toContain(firstTestEvent.date);
    });

    it('will render the build event name', () => {
      expect(wrapper.findByTestId('vsa-stage-event-build-name').text()).toContain(
        firstTestEvent.name,
      );
    });
  });

  it('isLoading = true', () => {
    wrapper = createComponent({ isLoading: true }, true);
    expect(wrapper.find(GlLoadingIcon).exists()).toEqual(true);
  });

  describe('with no stageEvents', () => {
    beforeEach(() => {
      wrapper = createComponent({ stageEvents: [] });
    });

    it('will render the empty state', () => {
      expect(wrapper.find(GlEmptyState).exists()).toBe(true);
    });

    it('will display the default no data message', () => {
      expect(wrapper.html()).toContain(notEnoughDataError);
    });
  });

  describe('emptyStateMessage set', () => {
    beforeEach(() => {
      wrapper = createComponent({ stageEvents: [], emptyStateMessage });
    });

    it('will display the custom message', () => {
      expect(wrapper.html()).not.toContain(notEnoughDataError);
      expect(wrapper.html()).toContain(emptyStateMessage);
    });
  });
});

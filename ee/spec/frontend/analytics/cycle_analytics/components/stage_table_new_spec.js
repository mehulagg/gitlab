import { GlEmptyState, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, mount } from '@vue/test-utils';
import StageTableNew from 'ee/analytics/cycle_analytics/components/stage_table_new.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { issueEvents, issueStage, testStage } from '../mock_data';

let wrapper = null;

const noDataSvgPath = 'path/to/no/data';
const emptyStateMessage = 'Too much data';
const notEnoughDataError = "We don't have enough data to show this stage.";

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
        'gl-loading-icon': true,
        'gl-empty-state': true,
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

  it('will render an event with an iid', () => {
    const [firstEvent] = issueEvents;
    wrapper = createComponent({ stageEvents: [firstEvent] });
    expect(wrapper.findByTestId('vsa-stage-event-build-status').exists()).toBe(false);
    expect(wrapper.findByTestId('vsa-stage-event').html()).toMatchSnapshot();
  });

  it('will render an event with an id', () => {
    const [firstEvent] = issueEvents;
    wrapper = createComponent({
      stageEvents: [{ ...firstEvent, id: 222 }],
      currentStage: { ...issueStage, custom: false },
    });
    expect(wrapper.findByTestId('vsa-stage-event-build-status').exists()).toBe(false);
    expect(wrapper.findByTestId('vsa-stage-event').html()).toMatchSnapshot();
  });

  it('will render build status for the default `test` stage', () => {
    const [firstEvent] = issueEvents;
    wrapper = createComponent({
      stageEvents: [{ ...firstEvent, id: 222 }],
      currentStage: { ...testStage, custom: false },
    });
    expect(wrapper.findByTestId('vsa-stage-event-build-status').exists()).toBe(true);
    expect(wrapper.findByTestId('vsa-stage-event').html()).toMatchSnapshot();
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

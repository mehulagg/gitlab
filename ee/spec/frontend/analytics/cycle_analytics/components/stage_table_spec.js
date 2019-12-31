import Vue from 'vue';
import { shallowMount, mount } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import StageTable from 'ee/analytics/cycle_analytics/components/stage_table.vue';
import {
  issueEvents,
  issueStage,
  allowedStages,
  groupLabels,
  customStageEvents,
  stageMedians as medians,
} from '../mock_data';

let wrapper = null;
const $sel = {
  nav: '.stage-nav',
  navItems: '.stage-nav-item',
  eventList: '.stage-events',
  events: '.stage-event-item',
  description: '.events-description',
  headers: '.col-headers li',
  headersList: '.col-headers',
  illustration: '.empty-state .svg-content',
};

const headers = ['Stage', 'Median', issueStage.legend, 'Total Time'];
const noDataSvgPath = 'path/to/no/data';
const noAccessSvgPath = 'path/to/no/access';

function createComponent(props = {}, shallow = false) {
  const func = shallow ? shallowMount : mount;
  return func(StageTable, {
    propsData: {
      stages: allowedStages,
      currentStage: issueStage,
      currentStageEvents: issueEvents,
      labels: groupLabels,
      isLoading: false,
      isLoadingSummaryData: false,
      isEmptyStage: false,
      isSavingCustomStage: false,
      isCreatingCustomStage: false,
      isEditingCustomStage: false,
      noDataSvgPath,
      noAccessSvgPath,
      canEditStages: false,
      customStageFormEvents: customStageEvents,
      medians,
      ...props,
    },
    stubs: {
      'gl-loading-icon': true,
    },
    sync: false,
    attachToDocument: true,
  });
}

describe('StageTable', () => {
  describe('headers', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });
    it('will render the headers', () => {
      const renderedHeaders = wrapper.findAll($sel.headers);
      expect(renderedHeaders.length).toEqual(headers.length);

      const headerText = wrapper.find($sel.headersList).text();
      headers.forEach(title => {
        expect(headerText).toContain(title);
      });
    });
  });

  describe('is loaded with data', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('will render the events list', () => {
      expect(wrapper.find($sel.eventList).exists()).toBeTruthy();
    });

    it('will render the correct stages', () => {
      const evs = wrapper.findAll({ name: 'StageNavItem' });
      expect(evs.length).toEqual(allowedStages.length);

      const nav = wrapper.find($sel.nav).html();
      allowedStages.forEach(stage => {
        expect(nav).toContain(stage.title);
      });
    });

    it('will render the current stage', () => {
      expect(wrapper.find($sel.description).exists()).toBeTruthy();
      expect(wrapper.find($sel.description).text()).toEqual(issueStage.description);
    });

    it('will render the event list', () => {
      expect(wrapper.find($sel.eventList).exists()).toBeTruthy();
      expect(wrapper.findAll($sel.events).exists()).toBeTruthy();
    });

    it('will render the correct events', () => {
      const evs = wrapper.findAll($sel.events);
      expect(evs.length).toEqual(issueEvents.length);

      const evshtml = wrapper.find($sel.eventList).html();
      issueEvents.forEach(ev => {
        expect(evshtml).toContain(ev.title);
      });
    });

    function selectStage(index) {
      wrapper
        .findAll($sel.navItems)
        .at(index)
        .trigger('click');
    }

    describe('when a stage is clicked', () => {
      it('will emit `selectStage`', done => {
        expect(wrapper.emitted('selectStage')).toBeUndefined();

        selectStage(1);

        Vue.nextTick(() => {
          expect(wrapper.emitted().selectStage.length).toEqual(1);
          done();
        });
      });

      it('will emit `selectStage` with the new stage title', done => {
        const secondStage = allowedStages[1];

        selectStage(1);

        Vue.nextTick(() => {
          const [params] = wrapper.emitted('selectStage')[0];
          expect(params).toMatchObject({ title: secondStage.title });
          done();
        });
      });
    });
  });

  it('isLoading = true', () => {
    wrapper = createComponent({ isLoading: true }, true);
    expect(wrapper.find(GlLoadingIcon).exists()).toEqual(true);
  });

  describe('isEmptyStage = true', () => {
    beforeEach(() => {
      wrapper = createComponent({ isEmptyStage: true });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('will render the empty stage illustration', () => {
      expect(wrapper.find($sel.illustration).exists()).toBeTruthy();
      expect(wrapper.find($sel.illustration).html()).toContain(noDataSvgPath);
    });

    it('will display the no data message', () => {
      expect(wrapper.html()).toContain("We don't have enough data to show this stage.");
    });
  });

  describe('canEditStages = true', () => {
    beforeEach(() => {
      wrapper = createComponent({
        canEditStages: true,
      });
    });

    afterEach(() => {
      wrapper.destroy();
    });
    it('will render the add a stage button', () => {
      expect(wrapper.html()).toContain('Add a stage');
    });
  });
});

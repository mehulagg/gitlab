import { shallowMount, mount } from '@vue/test-utils';
import StageBuildItem from 'ee/analytics/cycle_analytics/components/stage_build_item.vue';
import { renderTotalTime } from '../helpers';
import { stagingStage as stage, stagingEvents as events } from '../mock_data';

function createComponent(props = {}, shallow = true) {
  const func = shallow ? shallowMount : mount;
  return func(StageBuildItem, {
    propsData: {
      stage,
      events,
      ...props,
    },
  });
}

const $sel = {
  item: '.stage-event-item',
  description: '.events-description',
  issueDate: '.issue-date',
  author: '.issue-author-link',
  time: '.item-time',
  commit: '.commit-sha',
  branch: '.ref-name',
  mrBranch: '.merge-request-branch',
  pipeline: '.pipeline-id',
  buildName: '.item-build-name',
  buildDate: '.build-date',
  avatar: '.avatar',
};

describe('StageBuildItem', () => {
  let wrapper = null;

  beforeEach(() => {
    wrapper = createComponent({}, false);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('will render the events list', () => {
    const items = wrapper.findAll($sel.item);
    expect(items.length > 0).toBe(true);
    expect(items).toHaveLength(events.length);
  });
  it('will render the build pipeline id', () => {
    events.forEach((item, index) => {
      const elem = wrapper.findAll($sel.item).at(index);
      expect(elem.find($sel.pipeline).text()).toEqual(`#${item.id}`);
    });
  });

  it('will render the branch', () => {
    events.forEach((item, index) => {
      const elem = wrapper.findAll($sel.item).at(index);
      expect(elem.find($sel.branch).text()).toEqual(item.branch.name);
      expect(elem.find($sel.branch).attributes('href')).toEqual(item.branch.url);
    });
  });

  it('will render the commit sha of the event', () => {
    events.forEach((item, index) => {
      const elem = wrapper.findAll($sel.item).at(index);
      expect(elem.find($sel.commit).text()).toEqual(item.shortSha);
    });
  });

  it('will render the total time', () => {
    events.forEach((item, index) => {
      const elem = wrapper.findAll($sel.item).at(index);
      renderTotalTime($sel.time, elem, item.totalTime);
    });
  });

  describe('withBuildStatus = false', () => {
    beforeEach(() => {
      wrapper = createComponent({ withBuildStatus: false }, false);
    });
    afterEach(() => {
      wrapper.destroy();
    });
    it('will render the build date', () => {
      events.forEach((item, index) => {
        const elem = wrapper.findAll($sel.buildDate).at(index);
        expect(elem.find($sel.buildDate).text()).toEqual(item.date);
      });
    });

    it('will render the authors avatar', () => {
      events.forEach((item, index) => {
        const elem = wrapper.findAll($sel.item).at(index);
        expect(elem.find($sel.avatar).exists()).toEqual(true);
        expect(elem.find($sel.avatar).attributes('src')).toContain(item.author.avatarUrl);
      });
    });

    it('will render a link to the author', () => {
      events.forEach((item, index) => {
        const elem = wrapper.findAll($sel.item).at(index);
        expect(elem.find($sel.author).text()).toEqual(item.author.name);
        expect(elem.find($sel.author).attributes('href')).toEqual(item.author.webUrl);
      });
    });
  });

  describe('withBuildStatus = true', () => {
    beforeEach(() => {
      wrapper = createComponent({ withBuildStatus: true }, false);
    });

    afterEach(() => {
      wrapper.destroy();
    });
    it('will render the build pipeline id', () => {
      events.forEach((item, index) => {
        const elem = wrapper.findAll($sel.item).at(index);
        expect(elem.find($sel.buildName).text()).toContain(item.name);
        expect(elem.find('.icon-build-status').exists()).toBe(true);
      });
    });

    it('will render the issue created date', () => {
      events.forEach((item, index) => {
        const elem = wrapper.findAll($sel.item).at(index);
        expect(elem.find($sel.issueDate).text()).toEqual(item.date);
      });
    });
  });
});

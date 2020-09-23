import { shallowMount, mount } from '@vue/test-utils';
import StageEventItem from 'ee/analytics/cycle_analytics/components/stage_event_item.vue';
import { renderTotalTime } from '../helpers';
import { issueStage as stage, issueEvents as events } from '../mock_data';

function createComponent(props = {}, shallow = true) {
  const func = shallow ? shallowMount : mount;
  return func(StageEventItem, {
    propsData: {
      stage,
      events,
      ...props,
    },
  });
}

const $sel = {
  item: '.stage-event-item',
  title: '.item-title',
  issueLink: '.issue-link',
  issueDate: '.issue-date',
  author: '.issue-author-link',
  avatar: '.avatar',
  time: '.item-time',
};

describe('StageEventItem', () => {
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

  it('will render the title of each event', () => {
    events.forEach((item, index) => {
      const elem = wrapper.findAll($sel.item).at(index);
      expect(elem.find($sel.title).text()).toContain(item.title);
    });
  });

  it('will render the issue link', () => {
    events.forEach((item, index) => {
      const elem = wrapper.findAll($sel.item).at(index);
      expect(elem.find($sel.issueLink).text()).toEqual(`#${item.iid}`);
    });
  });

  it('will render the total time', () => {
    events.forEach((item, index) => {
      const elem = wrapper.findAll($sel.item).at(index);
      renderTotalTime($sel.time, elem, item.totalTime);
    });
  });
  it('will render the issue created date', () => {
    events.forEach((item, index) => {
      const elem = wrapper.findAll($sel.item).at(index);
      expect(elem.find($sel.issueDate).text()).toEqual(item.createdAt);
    });
  });

  it('will render a link to the author', () => {
    events.forEach((item, index) => {
      const elem = wrapper.findAll($sel.item).at(index);
      expect(elem.find($sel.author).text()).toEqual(item.author.name);
      expect(elem.find($sel.author).attributes('href')).toEqual(item.author.webUrl);
    });
  });

  it('will render the authors avatar', () => {
    events.forEach((item, index) => {
      const elem = wrapper.findAll($sel.item).at(index);
      expect(elem.find($sel.avatar).exists()).toEqual(true);
      expect(elem.find($sel.avatar).attributes('src')).toContain(item.author.avatarUrl);
    });
  });
});

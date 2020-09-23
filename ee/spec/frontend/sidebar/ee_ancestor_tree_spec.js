import Vue from 'vue';
import { escape } from 'lodash';
import ancestorsTree from 'ee/sidebar/components/ancestors_tree/ancestors_tree.vue';
import mountComponent from 'helpers/vue_mount_component_helper';

describe('AncestorsTreeContainer', () => {
  let vm;
  const ancestors = [
    { id: 1, url: '', title: 'A', state: 'open' },
    { id: 2, url: '', title: 'B', state: 'open' },
  ];

  beforeEach(() => {
    const AncestorsTreeContainer = Vue.extend(ancestorsTree);
    vm = mountComponent(AncestorsTreeContainer, { ancestors, isFetching: false });
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('renders all ancestors rows', () => {
    expect(vm.$el.querySelectorAll('.vertical-timeline-row')).toHaveLength(ancestors.length);
  });

  it('renders tooltip with the immediate parent', () => {
    expect(vm.$el.querySelector('.collapse-truncated-title').innerText.trim()).toBe(
      ancestors.slice(-1)[0].title,
    );
  });

  it('does not render timeline when fetching', () => {
    vm.$props.isFetching = true;

    return vm.$nextTick().then(() => {
      expect(vm.$el.querySelector('.vertical-timeline')).toBeNull();
      expect(vm.$el.querySelector('.value')).toBeNull();
    });
  });

  it('render `None` when ancestors is an empty array', () => {
    vm.$props.ancestors = [];

    return vm.$nextTick().then(() => {
      expect(vm.$el.querySelector('.vertical-timeline')).toBeNull();
      expect(vm.$el.querySelector('.value')).not.toBeNull();
    });
  });

  it('render loading icon when isFetching is true', () => {
    vm.$props.isFetching = true;

    return vm.$nextTick().then(() => {
      expect(vm.$el.querySelector('.fa-spinner')).toBeDefined();
    });
  });

  it('escapes html in the tooltip', () => {
    const title = '<script>alert(1);</script>';
    const escapedTitle = escape(title);

    vm.$props.ancestors = [{ id: 1, url: '', title, state: 'open' }];

    return vm.$nextTick().then(() => {
      const tooltip = vm.$el.querySelector('.collapse-truncated-title');

      expect(tooltip.innerText).toBe(escapedTitle);
    });
  });
});

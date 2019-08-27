import Vue from 'vue';
import { escape } from 'lodash-es';
import ancestorsTree from 'ee/sidebar/components/ancestors_tree/ancestors_tree.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';

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
    expect(vm.$el.querySelectorAll('.vertical-timeline-row').length).toBe(ancestors.length);
  });

  it('renders tooltip with the immediate parent', () => {
    expect(vm.$el.querySelector('.collapse-truncated-title').innerText.trim()).toBe(
      ancestors.slice(-1)[0].title,
    );
  });

  it('does not render timeline when fetching', done => {
    vm.$props.isFetching = true;
    vm.$nextTick()
      .then(() => {
        expect(vm.$el.querySelector('.vertical-timeline')).toBeNull();
        expect(vm.$el.querySelector('.value')).toBeNull();
      })
      .then(done)
      .catch(done.fail);
  });

  it('render `None` when ancestors is an empty array', done => {
    vm.$props.ancestors = [];
    vm.$nextTick()
      .then(() => {
        expect(vm.$el.querySelector('.vertical-timeline')).toBeNull();
        expect(vm.$el.querySelector('.value')).not.toBeNull();
      })
      .then(done)
      .catch(done.fail);
  });

  it('render loading icon when isFetching is true', done => {
    vm.$props.isFetching = true;
    vm.$nextTick()
      .then(() => {
        expect(vm.$el.querySelector('.fa-spinner')).toBeDefined();
      })
      .then(done)
      .catch(done.fail);
  });

  it('escapes html in the tooltip', done => {
    const title = '<script>alert(1);</script>';
    const escapedTitle = escape(title);

    vm.$props.ancestors = [{ id: 1, url: '', title, state: 'open' }];
    vm.$nextTick()
      .then(() => {
        const tooltip = vm.$el.querySelector('.collapse-truncated-title');

        expect(tooltip.innerText).toBe(escapedTitle);
      })
      .then(done)
      .catch(done.fail);
  });
});

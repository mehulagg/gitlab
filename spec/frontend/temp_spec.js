import { mount } from '@vue/test-utils';
import Vue from 'vue';

describe('test', () => {
  const ChildComponent = Vue.extend({
    props: {
      things: {
        type: Array,
        required: true,
      },
      loading: {
        type: Boolean,
        required: false,
      },
    },
    template: '<div><p v-for="thing in things">{{thing.foo}} - {{thing.bar}}</p></div>',
  });
  const TestComponent = Vue.extend({
    components: {
      ChildComponent,
    },
    data() {
      return {
        things: [{ foo: '123', bar: 'abc' }, { foo: '456', bar: 'def' }],
        loading: false,
      };
    },
    watch: {
      things(val) {
        console.log('val');
      },
    },
    template: '<child-component v-if="things.length" :things="things" :loading="loading" />',
  });

  let wrapper = null;

  beforeEach(async () => {
    wrapper = mount(TestComponent);

    await wrapper.vm.$nextTick();
  });

  afterEach(() => {
    wrapper.vm.destroy();
    wrapper = null;
  });

  it('breaks things', () => {
    const expected = {
      things: [{ foo: '12', bar: 'abc' }, { foo: '456', bar: 'def' }],
    };
    expect(wrapper.find(ChildComponent).props()).toEqual(expected);
  });
});

import { mount } from '@vue/test-utils';
import LoadedTestComponent from './temp_test_component.vue';
import LoadedChildComponent from './temp_child_component.vue';

const InlineChild = {
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
  // template:
  //   '<div><p v-for="thing in things" :key="thing.foo">{{thing.foo}} - {{thing.bar}}</p></div>',
  render(h) {
    return h('div', this.things.map(({ foo, bar }) => h('p', { key: foo }, [`${foo} - ${bar}`])));
  },
};
const InlineTest = {
  components: {
    ChildComponent: InlineChild,
  },
  data() {
    return {
      things: [{ foo: '123', bar: 'abc' }, { foo: '456', bar: 'def' }],
      loading: false,
    };
  },
  watch: {
    things(val) {
      console.log(val);
    },
  },
  // template:
  // '<div><child-component v-if="things.length" :things="things" :loading="loading" /></div>',
  render(h) {
    return h('div', [
      [
        h('child-component', {
          attrs: {
            things: this.things,
            loading: this.loading,
          },
        }),
      ],
    ]);
  },
};

const InlineChildLoaded = (function() {
  const exports = {};
  Object.defineProperty(exports, '__esModule', {
    value: true,
  });
  exports.default = void 0;
  var _default = {
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
  };
  exports.default = _default;
  var __options__ =
    typeof exports.default === 'function' ? exports.default.options : exports.default;
  var render = function(h) {
    var _vm = this;
    /* istanbul ignore next */
    var _c = h;
    return _c(
      'div',
      _vm.things.map(function(thing) {
        return _c('p', { key: thing.foo }, [`${thing.foo} - ${thing.bar}`]);
      }),
      0,
    );
  };
  var staticRenderFns = [];
  render._withStripped = true;

  __options__.render = render;
  __options__.staticRenderFns = staticRenderFns;

  return exports.default;
})();
const InlineTestLoaded = (function() {
  const exports = {};
  Object.defineProperty(exports, '__esModule', {
    value: true,
  });
  exports.default = void 0;

  var _default = {
    components: {
      ChildComponent: InlineChildLoaded,
    },

    data() {
      return {
        things: [
          {
            foo: '123',
            bar: 'abc',
          },
          {
            foo: '456',
            bar: 'def',
          },
        ],
        loading: false,
      };
    },

    watch: {
      things(val) {
        console.log(val);
      },
    },
  };
  exports.default = _default;
  var __options__ =
    typeof exports.default === 'function' ? exports.default.options : exports.default;
  var render = function(h) {
    var _vm = this;
    /* istanbul ignore next */
    var _c = h;
    return _c(
      'div',
      [
        _c('child-component', {
          attrs: { things: _vm.things, loading: _vm.loading },
        }),
      ],
      1,
    );
  };
  var staticRenderFns = [];
  render._withStripped = true;

  __options__.render = render;
  __options__.staticRenderFns = staticRenderFns;
  return exports.default;
})();

// const TestComponent = LoadedTestComponent;
// const ChildComponent = LoadedChildComponent;
const TestComponent = InlineTestLoaded;
const ChildComponent = InlineChildLoaded;

describe('test', () => {
  let wrapper = null;

  beforeEach(async () => {
    wrapper = mount(TestComponent);

    await wrapper.vm.$nextTick();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('breaks things', () => {
    console.log(Object.getOwnPropertyDescriptors(wrapper.find(ChildComponent).props().things[0]));
    const expected = {
      loading: true,
      things: [{ foo: '123', bar: 'abc' }, { foo: '456', bar: 'def' }],
    };
    expect(wrapper.find(ChildComponent).props()).toEqual(expected);
  });
});

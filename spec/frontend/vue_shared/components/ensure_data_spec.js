import { GlEmptyState } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { mount } from '@vue/test-utils';
import EnsureData from '~/vue_shared/components/ensure_data.vue';

const mockData = { message: 'Hello there' };
const mockTitle = 'An error happened';
const mockDescription = 'Please contact us!';
const mockSvgPath = '/my.svg';

const MockChildComponent = {
  inject: ['message'],
  render(createElement) {
    return createElement('h1', this.message);
  },
};

const MockParentComponent = {
  components: {
    MockChildComponent,
  },
  props: {
    message: {
      type: String,
      required: true,
    },
  },
  render(createElement) {
    return createElement('div', [this.message, createElement(MockChildComponent)]);
  },
};

describe('EnsureData', () => {
  let wrapper;

  function createComponent(propsData = {}) {
    const {
      parse = () => mockData,
      data = mockData,
      shouldLog = false,
      title = mockTitle,
      description = mockDescription,
      svgPath = mockSvgPath,
    } = propsData;

    return mount(EnsureData, {
      propsData: {
        parse,
        data,
        shouldLog,
        title,
        description,
        svgPath,
      },
      scopedSlots: {
        app(props) {
          return this.$createElement({ extends: MockParentComponent, provide: props }, { props });
        },
      },
    });
  }

  beforeEach(() => {
    Sentry.captureException = jest.fn();
  });

  afterEach(() => {
    wrapper.destroy();
    Sentry.captureException.mockClear();
  });

  it('should render GlEmptyState when parse throws', () => {
    wrapper = createComponent({
      parse: () => {
        throw new Error();
      },
    });

    expect(wrapper.find(MockChildComponent).exists()).toBe(false);
    expect(wrapper.find(GlEmptyState).exists()).toBe(true);
    expect(Sentry.captureException).not.toHaveBeenCalled();
  });

  it('should log to Sentry shouldLog=true and parse throws', () => {
    const error = new Error('Error!');
    wrapper = createComponent({
      shouldLog: true,
      parse: () => {
        throw error;
      },
    });

    expect(Sentry.captureException).toHaveBeenCalledWith(error);
  });

  it('should render MockChildComponent when parse succeeds', () => {
    wrapper = createComponent();

    expect(wrapper.find(GlEmptyState).exists()).toBe(false);
    expect(wrapper.find(MockChildComponent).exists()).toBe(true);
  });

  it('enables user to provide data to child components when parse succeeds', () => {
    wrapper = createComponent();
    const childComponent = wrapper.find(MockChildComponent);
    expect(childComponent.html()).toBe(`<h1>${mockData.message}</h1>`);
    expect(childComponent.exists()).toBe(true);
  });

  it('enables user to pass props to parent component when parse succeeds', () => {
    wrapper = createComponent();
    expect(wrapper.props()).toMatchObject({ data: mockData });
  });
});

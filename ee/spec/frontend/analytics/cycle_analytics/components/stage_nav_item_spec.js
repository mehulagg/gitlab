// NOTE: more tests will be added in https://gitlab.com/gitlab-org/gitlab/issues/121613
import { shallowMount } from '@vue/test-utils';
import StageNavItem from 'ee/analytics/cycle_analytics/components/stage_nav_item.vue';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import { approximateDuration } from '~/lib/utils/datetime_utility';

describe('StageNavItem', () => {
  const title = 'Rad stage';
  const median = 50;
  const id = 1;

  function createComponent({ props = {}, opts = {} } = {}) {
    return shallowMount(StageNavItem, {
      propsData: {
        id,
        title,
        value: median,
        ...props,
      },
      directives: {
        GlTooltip: createMockDirective(),
      },
      ...opts,
    });
  }

  let wrapper = null;
  const findStageTitle = () => wrapper.find('[data-testid="stage-title"]');
  const findStageTooltip = () => getBinding(findStageTitle().element, 'gl-tooltip');
  const findStageMedian = () => wrapper.find({ ref: 'median' });
  const findDropdown = () => wrapper.find({ ref: 'dropdown' });
  const setFakeTitleWidth = value =>
    Object.defineProperty(findStageTitle().element, 'scrollWidth', {
      value,
    });

  afterEach(() => {
    wrapper.destroy();
  });

  it('with no median value', () => {
    wrapper = createComponent({ props: { value: null } });
    expect(findStageMedian().text()).toEqual('Not enough data');
  });

  describe('with data', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('renders the median value', () => {
      expect(findStageMedian().text()).toEqual(approximateDuration(median));
    });

    it('renders the stage title', () => {
      expect(findStageTitle().text()).toEqual(title);
    });

    it('renders the stage title without a tooltip', () => {
      const tt = findStageTooltip();
      expect(tt.value.title).toBeNull();
    });

    it('renders the dropdown with edit and remove options', () => {
      expect(findDropdown().exists()).toBe(true);
      expect(wrapper.find('[data-testid="edit-btn"]').exists()).toBe(true);
      expect(wrapper.find('[data-testid="remove-btn"]').exists()).toBe(true);
      expect(wrapper.find('[data-testid="hide-btn"]').exists()).toBe(false);
    });
  });

  describe('with data an a non-default state', () => {
    beforeEach(() => {
      wrapper = createComponent({ props: { isDefaultStage: true } });
    });

    it('renders the dropdown with a hide option', () => {
      expect(findDropdown().exists()).toBe(true);
      expect(wrapper.find('[data-testid="hide-btn"]').exists()).toBe(true);
      expect(wrapper.find('[data-testid="edit-btn"]').exists()).toBe(false);
      expect(wrapper.find('[data-testid="remove-btn"]').exists()).toBe(false);
    });
  });

  describe('with a really long name', () => {
    const longTitle = 'This is a very long stage name that is intended to break the ui';

    beforeEach(() => {
      wrapper = createComponent({
        props: { title: longTitle },
        opts: {
          data() {
            return { isTitleOverflowing: true };
          },
        },
      });

      // JSDom does not calculate scrollWidth / offsetWidth so we fake it
      setFakeTitleWidth(1000);
      wrapper.vm.$forceUpdate();
      return wrapper.vm.$nextTick();
    });

    it('renders the tooltip', () => {
      const tt = findStageTooltip();
      expect(tt.value).toBeDefined();
      expect(tt.value.title).toBe(longTitle);
    });
  });
});

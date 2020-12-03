import { shallowMount } from '@vue/test-utils';
import { GlEmptyState } from '@gitlab/ui';
import OnCallScheduleWrapper, {
  i18n,
} from 'ee/oncall_schedules/components/oncall_schedules_wrapper.vue';

describe('AlertManagementEmptyState', () => {
  let wrapper;
  const emptyOncallSchedulesSvgPath = 'illustration/path.svg';

  function mountComponent() {
    wrapper = shallowMount(OnCallScheduleWrapper, {
      provide: {
        emptyOncallSchedulesSvgPath,
      },
    });
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findEmptyState = () => wrapper.find(GlEmptyState);

  describe('Empty state', () => {
    it('shows empty state and passed correct attributes to it', () => {
      expect(findEmptyState().exists()).toBe(true);
      expect(findEmptyState().attributes('title')).toBe(i18n.emptyState.title);
      expect(findEmptyState().attributes('description')).toBe(i18n.emptyState.description);
      expect(findEmptyState().attributes('svgpath')).toBe(emptyOncallSchedulesSvgPath);
    });
  });
});

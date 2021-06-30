import { GlSkeletonLoader } from '@gitlab/ui';
import { GlSingleStat } from '@gitlab/ui/dist/charts';
import { shallowMount } from '@vue/test-utils';
import ThroughputStats from 'ee/analytics/merge_request_analytics/components/throughput_stats.vue';
import { stats } from '../mock_data';

describe('ThroughputStats', () => {
  let wrapper;

  const createWrapper = (props) => {
    return shallowMount(ThroughputStats, {
      propsData: {
        stats,
        ...props,
      },
    });
  };

  describe('default behaviour', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    it('displays a GlSingleStat component for each stat entry', () => {
      expect(wrapper.findAll(GlSingleStat)).toHaveLength(stats.length);
    });

    it('passes the GlSingleStat the correct props', () => {
      const component = wrapper.findAll(GlSingleStat).at(0);
      const { title, unit, value } = stats[0];

      expect(component.props('title')).toBe(title);
      expect(component.props('unit')).toBe(unit);
      expect(component.props('value')).toBe(value);
    });

    it('does not display any GlSkeletonLoader components', () => {
      expect(wrapper.findAll(GlSkeletonLoader)).toHaveLength(0);
    });
  });

  describe('loading', () => {
    beforeEach(() => {
      wrapper = createWrapper({ isLoading: true });
    });

    it('displays a GlSkeletonLoader component for each stat entry', () => {
      expect(wrapper.findAll(GlSkeletonLoader)).toHaveLength(stats.length);
    });

    it('does not display any GlSingleStat components', () => {
      expect(wrapper.findAll(GlSingleStat)).toHaveLength(0);
    });
  });
});

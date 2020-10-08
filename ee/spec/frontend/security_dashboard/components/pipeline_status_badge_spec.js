import { GlBadge } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import PipelineStatusBadge from 'ee/security_dashboard/components/pipeline_status_badge.vue';

describe('Pipeline status badge', () => {
  const pipelineSecurityBuildsFailedPath = '/some/path/to/failed/jobs';

  let wrapper;

  const createWrapper = ({ pipelineSecurityBuildsFailedCount }) => {
    wrapper = shallowMount(PipelineStatusBadge, {
      provide: {
        pipelineSecurityBuildsFailedCount,
        pipelineSecurityBuildsFailedPath,
      },
      stubs: { GlBadge },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('does not render when there are no failed jobs', () => {
    createWrapper({ pipelineSecurityBuildsFailedCount: 0 });
    expect(wrapper.text()).toBe('');
  });

  it('displays correct message for 5 failed jobs', () => {
    createWrapper({ pipelineSecurityBuildsFailedCount: 5 });
    expect(wrapper.text()).toBe('5 failed security jobs');
  });

  it('displays correct message for 1 failed job', () => {
    createWrapper({ pipelineSecurityBuildsFailedCount: 1 });
    expect(wrapper.text()).toBe('1 failed security job');
  });

  it('links to the correct path', () => {
    createWrapper({ pipelineSecurityBuildsFailedCount: 5 });
    expect(wrapper.find(GlBadge).attributes('href')).toBe(pipelineSecurityBuildsFailedPath);
  });
});

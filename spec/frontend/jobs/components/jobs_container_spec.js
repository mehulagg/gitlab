import { GlLink } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import JobsContainer from '~/jobs/components/jobs_container.vue';

describe('Jobs List block', () => {
  let wrapper;

  const retried = {
    status: {
      details_path: '/gitlab-org/gitlab-foss/pipelines/28029444',
      group: 'success',
      has_details: true,
      icon: 'status_success',
      label: 'passed',
      text: 'passed',
      tooltip: 'passed',
    },
    id: 233432756,
    tooltip: 'build - passed',
    retried: true,
  };

  const active = {
    name: 'test',
    status: {
      details_path: '/gitlab-org/gitlab-foss/pipelines/28029444',
      group: 'success',
      has_details: true,
      icon: 'status_success',
      label: 'passed',
      text: 'passed',
      tooltip: 'passed',
    },
    id: 2322756,
    tooltip: 'build - passed',
    active: true,
  };

  const job = {
    name: 'build',
    status: {
      details_path: '/gitlab-org/gitlab-foss/pipelines/28029444',
      group: 'success',
      has_details: true,
      icon: 'status_success',
      label: 'passed',
      text: 'passed',
      tooltip: 'passed',
    },
    id: 232153,
    tooltip: 'build - passed',
  };

  const findJob = () => wrapper.findComponent(GlLink);
  const findAllJobs = () => wrapper.findAll(GlLink);

  const findArrowIcon = () => wrapper.find('[data-testid="arrow-right-icon"]');
  const findRetryIcon = () => wrapper.find('[data-testid="retry-icon"]');

  const createComponent = (props) => {
    wrapper = mount(JobsContainer, {
      propsData: {
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders list of jobs', () => {
    createComponent({
      jobs: [job, retried, active],
      jobId: 12313,
    });

    expect(findAllJobs()).toHaveLength(3);
  });

  it('renders arrow right when job id matches `jobId`', () => {
    createComponent({
      jobs: [active],
      jobId: active.id,
    });

    expect(findArrowIcon().exists()).toBe(true);
  });

  it('does not render arrow right when job is not active', () => {
    createComponent({
      jobs: [job],
      jobId: active.id,
    });

    expect(findArrowIcon().exists()).toBe(false);
  });

  it('renders job name when present', () => {
    createComponent({
      jobs: [job],
      jobId: active.id,
    });

    expect(findJob().text()).toContain(job.name);
    expect(findJob().text()).not.toContain(job.id);
  });

  it('renders job id when job name is not available', () => {
    createComponent({
      jobs: [retried],
      jobId: active.id,
    });

    expect(findJob().text()).toContain(retried.id);
  });

  it('links to the job page', () => {
    createComponent({
      jobs: [job],
      jobId: active.id,
    });

    expect(findJob().attributes('href')).toBe(job.status.details_path);
  });

  it('renders retry icon when job was retried', () => {
    createComponent({
      jobs: [retried],
      jobId: active.id,
    });

    expect(findRetryIcon().exists()).toBe(true);
  });

  it('does not render retry icon when job was not retried', () => {
    createComponent({
      jobs: [job],
      jobId: active.id,
    });

    expect(findRetryIcon().exists()).toBe(false);
  });
});

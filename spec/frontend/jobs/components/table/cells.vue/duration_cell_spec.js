import { shallowMount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import DurationCell from '~/jobs/components/table/cells/duration_cell.vue';

describe('Duration Cell', () => {
  let wrapper;

  const findJobDuration = () => wrapper.findByTestId('job-duration');
  const findJobFinishedTime = () => wrapper.findByTestId('job-finished-time');
  const findDurationIcon = () => wrapper.findByTestId('duration-icon');
  const findFinishedTimeIcon = () => wrapper.findByTestId('finished-time-icon');

  const createComponent = (props) => {
    wrapper = extendedWrapper(
      shallowMount(DurationCell, {
        propsData: {
          job: {
            ...props,
          },
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('does not display any duration or finished time', () => {
    createComponent();

    expect(findJobDuration().exists()).toBe(false);
    expect(findJobFinishedTime().exists()).toBe(false);
  });

  it('displays duration and finished time', () => {
    const props = {
      duration: 7,
      finishedAt: '2021-04-26T13:37:52Z',
    };

    createComponent(props);

    expect(findJobDuration().exists()).toBe(true);
    expect(findJobFinishedTime().exists()).toBe(true);
  });

  it('displays just the duration of the job', () => {
    const props = {
      duration: 7,
    };

    createComponent(props);

    expect(findJobDuration().exists()).toBe(true);
    expect(findJobFinishedTime().exists()).toBe(false);
  });

  it('displays just the finished time of the job', () => {
    const props = {
      finishedAt: '2021-04-26T13:37:52Z',
    };

    createComponent(props);

    expect(findJobFinishedTime().exists()).toBe(true);
    expect(findJobDuration().exists()).toBe(false);
  });

  it('displays icons for finished time and duration', () => {
    const props = {
      duration: 7,
      finishedAt: '2021-04-26T13:37:52Z',
    };

    createComponent(props);

    expect(findFinishedTimeIcon().props('name')).toBe('calendar');
    expect(findDurationIcon().props('name')).toBe('timer');
  });
});

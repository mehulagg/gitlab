import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import GroupActivityCard from 'ee/analytics/group_analytics/components/group_activity_card.vue';
import Api from 'ee/api';
import waitForPromises from 'helpers/wait_for_promises';
import MetricCard from '~/analytics/shared/components/metric_card.vue';
import axios from '~/lib/utils/axios_utils';

const TEST_GROUP_ID = 'gitlab-org';
const TEST_GROUP_NAME = 'Gitlab Org';
const TEST_MERGE_REQUESTS_COUNT = { data: { merge_requests_count: 10 } };
const TEST_ISSUES_COUNT = { data: { issues_count: 20 } };
const TEST_NEW_MEMBERS_COUNT = { data: { new_members_count: 30 } };

describe('GroupActivity component', () => {
  let wrapper;
  let mock;

  const createComponent = () => {
    wrapper = mount(GroupActivityCard, {
      provide: {
        groupFullPath: TEST_GROUP_ID,
        groupName: TEST_GROUP_NAME,
      },
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);

    jest
      .spyOn(Api, 'groupActivityMergeRequestsCount')
      .mockReturnValue(Promise.resolve(TEST_MERGE_REQUESTS_COUNT));

    jest.spyOn(Api, 'groupActivityIssuesCount').mockReturnValue(Promise.resolve(TEST_ISSUES_COUNT));

    jest
      .spyOn(Api, 'groupActivityNewMembersCount')
      .mockReturnValue(Promise.resolve(TEST_NEW_MEMBERS_COUNT));
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  const findMetricCard = () => wrapper.find(MetricCard);

  it('matches the snapshot', () => {
    createComponent();

    return wrapper.vm
      .$nextTick()
      .then(waitForPromises)
      .then(() => {
        expect(wrapper.element).toMatchSnapshot();
      });
  });

  it('fetches MR and issue count and updates isLoading properly', () => {
    createComponent();

    expect(wrapper.vm.isLoading).toBe(true);

    return wrapper.vm
      .$nextTick()
      .then(() => {
        expect(Api.groupActivityMergeRequestsCount).toHaveBeenCalledWith(TEST_GROUP_ID);
        expect(Api.groupActivityIssuesCount).toHaveBeenCalledWith(TEST_GROUP_ID);
        expect(Api.groupActivityNewMembersCount).toHaveBeenCalledWith(TEST_GROUP_ID);

        waitForPromises();
      })
      .then(() => {
        expect(wrapper.vm.isLoading).toBe(false);
        expect(wrapper.vm.metrics.mergeRequests.value).toBe(10);
        expect(wrapper.vm.metrics.issues.value).toBe(20);
        expect(wrapper.vm.metrics.newMembers.value).toBe(30);
      });
  });

  it('passes the metrics array to the metric card', () => {
    createComponent();

    return wrapper.vm
      .$nextTick()
      .then(waitForPromises)
      .then(() => {
        expect(findMetricCard().props('metrics')).toEqual([
          { key: 'mergeRequests', value: 10, label: 'Merge Requests opened' },
          { key: 'issues', value: 20, label: 'Issues opened' },
          { key: 'newMembers', value: 30, label: 'Members added' },
        ]);
      });
  });
});

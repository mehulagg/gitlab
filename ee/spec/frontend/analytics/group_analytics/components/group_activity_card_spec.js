import { GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';
import { GlSingleStat } from '@gitlab/ui/dist/charts';
import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import GroupActivityCard from 'ee/analytics/group_analytics/components/group_activity_card.vue';
import Api from 'ee/api';
import waitForPromises from 'helpers/wait_for_promises';
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

  const findAllSkeletonLoaders = () => wrapper.findAllComponents(GlSkeletonLoading);
  const findAllSingleStats = () => wrapper.findAllComponents(GlSingleStat);

  it('fetches the metrics and updates isLoading properly', () => {
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

  it('updates the loading state properly', () => {
    createComponent();

    expect(findAllSkeletonLoaders()).toHaveLength(3);

    return wrapper.vm
      .$nextTick()
      .then(waitForPromises)
      .then(() => {
        expect(findAllSkeletonLoaders()).toHaveLength(0);
      });
  });

  describe('metrics', () => {
    beforeEach(() => {
      createComponent();
    });

    it.each`
      index | value | title
      ${0}  | ${10} | ${'Merge Requests opened'}
      ${1}  | ${20} | ${'Issues opened'}
      ${2}  | ${30} | ${'Members added'}
    `('renders a GlSingleStat for "$title"', ({ index, value, title }) => {
      const singleStat = findAllSingleStats().at(index);

      return wrapper.vm
        .$nextTick()
        .then(waitForPromises)
        .then(() => {
          expect(singleStat.props('value')).toBe(`${value}`);
          expect(singleStat.props('title')).toBe(title);
        });
    });
  });
});

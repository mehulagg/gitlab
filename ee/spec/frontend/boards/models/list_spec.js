import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import Issue from 'ee/boards/models/issue';
import List from 'ee/boards/models/list';
import { listObj } from 'jest/boards/mock_data';
import CeList from '~/boards/models/list';

describe('List model', () => {
  let list;
  let issue;
  let axiosMock;

  beforeEach(() => {
    axiosMock = new MockAdapter(axios);

    // We need to mock axios since `new List` below makes a network request
    axiosMock.onGet().replyOnce(200);

    list = new List(listObj);
    issue = new Issue({
      title: 'Testing',
      id: 2,
      iid: 2,
      labels: [],
      assignees: [],
      weight: 5,
    });
  });

  afterEach(() => {
    list = null;
    issue = null;
    axiosMock.restore();
  });

  it('inits totalWeight', () => {
    expect(list.totalWeight).toBe(0);
  });

  describe('getIssues', () => {
    it('calls CE getIssues', () => {
      const ceGetIssues = jest
        .spyOn(CeList.prototype, 'getIssues')
        .mockReturnValue(Promise.resolve({}));

      return list.getIssues().then(() => {
        expect(ceGetIssues).toHaveBeenCalled();
      });
    });

    it('sets total weight', () => {
      jest.spyOn(CeList.prototype, 'getIssues').mockReturnValue(
        Promise.resolve({
          total_weight: 11,
        }),
      );

      return list.getIssues().then(() => {
        expect(list.totalWeight).toBe(11);
      });
    });
  });

  describe('addIssue', () => {
    it('updates totalWeight', () => {
      list.addIssue(issue);

      expect(list.totalWeight).toBe(5);
    });

    it('calls CE addIssue with all args', () => {
      const ceAddIssue = jest.spyOn(CeList.prototype, 'addIssue');

      list.addIssue(issue, list, 2);

      expect(ceAddIssue).toHaveBeenCalledWith(issue, list, 2);
    });
  });

  describe('removeIssue', () => {
    beforeEach(() => {
      list.addIssue(issue);
    });

    it('updates totalWeight', () => {
      list.removeIssue(issue);

      expect(list.totalWeight).toBe(0);
    });

    it('calls CE removeIssue', () => {
      const ceRemoveIssue = jest.spyOn(CeList.prototype, 'removeIssue');

      list.removeIssue(issue);

      expect(ceRemoveIssue).toHaveBeenCalledWith(issue);
    });
  });
});

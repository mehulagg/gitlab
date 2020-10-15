import getters from 'ee/boards/stores/getters';
import {
  mockIssue,
  mockIssue3,
  mockIssue4,
  mockIssues,
  mockIssuesByListId,
  mockEpics,
  issues,
} from '../mock_data';

describe('EE Boards Store Getters', () => {
  const boardsState = {
    issuesByListId: mockIssuesByListId,
    epics: mockEpics,
    issues,
  };

  describe('getIssuesByEpic', () => {
    it('returns issues for a given listId and epicId', () => {
      const getIssues = () => mockIssues;
      expect(
        getters.getIssuesByEpic(boardsState, { getIssues })(
          'gid://gitlab/List/2',
          'gid://gitlab/Epic/41',
        ),
      ).toEqual([mockIssue]);
    });
  });

  describe('getUnassignedIssues', () => {
    it('returns issues not assigned to an epic for a given listId', () => {
      const getIssues = () => [mockIssue, mockIssue3, mockIssue4];
      expect(
        getters.getUnassignedIssues(boardsState, { getIssues })('gid://gitlab/List/1'),
      ).toEqual([mockIssue3, mockIssue4]);
    });
  });

  describe('getEpicById', () => {
    it('returns epic for a given id', () => {
      expect(getters.getEpicById(boardsState)(mockEpics[0].id)).toEqual(mockEpics[0]);
    });
  });
});

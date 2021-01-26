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

  describe('isSwimlanesOn', () => {
    afterEach(() => {
      window.gon = { features: {} };
    });

    describe('when swimlanes feature is true', () => {
      beforeEach(() => {
        window.gon = { features: { swimlanes: true } };
      });

      describe('when isShowingEpicsSwimlanes is true', () => {
        it('returns true', () => {
          const state = {
            isShowingEpicsSwimlanes: true,
          };

          expect(getters.isSwimlanesOn(state)).toBe(true);
        });
      });

      describe('when isShowingEpicsSwimlanes is false', () => {
        it('returns false', () => {
          const state = {
            isShowingEpicsSwimlanes: false,
          };

          expect(getters.isSwimlanesOn(state)).toBe(false);
        });
      });
    });

    describe('when swimlanes feature is false', () => {
      describe('when isShowingEpicsSwimlanes is true', () => {
        it('returns false', () => {
          const state = {
            isShowingEpicsSwimlanes: true,
          };

          expect(getters.isSwimlanesOn(state)).toBe(false);
        });
      });

      describe('when isShowingEpicsSwimlanes is false', () => {
        it('returns false', () => {
          const state = {
            isShowingEpicsSwimlanes: false,
          };

          expect(getters.isSwimlanesOn(state)).toBe(false);
        });
      });
    });
  });

  describe('getIssuesByEpic', () => {
    it('returns issues for a given listId and epicId', () => {
      const getIssuesByList = () => mockIssues;
      expect(
        getters.getIssuesByEpic(boardsState, { getIssuesByList })(
          'gid://gitlab/List/2',
          'gid://gitlab/Epic/41',
        ),
      ).toEqual([mockIssue]);
    });
  });

  describe('getUnassignedIssues', () => {
    it('returns issues not assigned to an epic for a given listId', () => {
      const getIssuesByList = () => [mockIssue, mockIssue3, mockIssue4];
      expect(
        getters.getUnassignedIssues(boardsState, { getIssuesByList })('gid://gitlab/List/1'),
      ).toEqual([mockIssue3, mockIssue4]);
    });
  });
});

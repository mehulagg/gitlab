import { ChildType } from 'ee/related_items_tree/constants';
import * as epicUtils from 'ee/related_items_tree/utils/epic_utils';

import { PathIdSeparator } from '~/related_issues/constants';

import { mockQueryResponse2, mockEpic1, mockIssue1 } from '../mock_data';

describe('RelatedItemsTree', () => {
  describe('epicUtils', () => {
    describe('sortChildren', () => {
      const paramA = {};
      const paramB = {};

      beforeEach(() => {
        paramA.relativePosition = -1;
        paramB.relativePosition = -1;
      });

      it('returns non-zero positive integer when paramA.relativePosition is greater than paramB.relativePosition', () => {
        paramA.relativePosition = 10;
        paramB.relativePosition = 5;

        expect(epicUtils.sortChildren(paramA, paramB) > -1).toBe(true);
      });

      it('returns non-zero negative integer when paramA.relativePosition is smaller than paramB.relativePosition', () => {
        paramA.relativePosition = 5;
        paramB.relativePosition = 10;

        expect(epicUtils.sortChildren(paramA, paramB) < 0).toBe(true);
      });

      it('returns zero when paramA.relativePosition is same as paramB.relativePosition', () => {
        paramA.relativePosition = 5;
        paramB.relativePosition = 5;

        expect(epicUtils.sortChildren(paramA, paramB)).toBe(0);
      });
    });

    describe('sortByState', () => {
      const items = [
        {
          state: 'closed',
        },
        {
          state: 'opened',
        },
        {
          state: 'closed',
        },
      ];
      const paramA = {};
      const paramB = {};

      it('returns non-zero positive integer when paramA.state is closed and paramB.state is opened', () => {
        paramA.state = 'closed';
        paramB.state = 'opened';

        expect(epicUtils.sortByState(paramA, paramB) > -1).toBe(true);
      });

      it('returns non-zero negative integer when paramA.state is opened and paramB.state is closed', () => {
        paramA.state = 'opened';
        paramB.state = 'closed';

        expect(epicUtils.sortByState(paramA, paramB) < 0).toBe(true);
      });

      it('returns zero when paramA.state is same as paramB.state', () => {
        paramA.state = 'opened';
        paramB.state = 'opened';

        expect(epicUtils.sortByState(paramA, paramB)).toBe(0);
      });

      it('reorders items by state, opened first, closed last', () => {
        expect(items.sort(epicUtils.sortByState)).toEqual([
          {
            state: 'opened',
          },
          {
            state: 'closed',
          },
          {
            state: 'closed',
          },
        ]);
      });
    });

    describe('formatChildItem', () => {
      it('returns new object from provided item object with pathIdSeparator assigned', () => {
        const item = {
          type: ChildType.Epic,
        };

        expect(epicUtils.formatChildItem(item)).toHaveProperty('type', ChildType.Epic);
        expect(epicUtils.formatChildItem(item)).toHaveProperty(
          'pathIdSeparator',
          PathIdSeparator.Epic,
        );
      });
    });

    describe('extractChildEpics', () => {
      it('returns updated epics array with `type` and `pathIdSeparator` assigned and `edges->node` nesting removed', () => {
        const formattedChildren = epicUtils.extractChildEpics(
          mockQueryResponse2.data.group.epic.children,
        );

        expect(formattedChildren).toHaveLength(
          mockQueryResponse2.data.group.epic.children.edges.length,
        );
        expect(formattedChildren[0]).toHaveProperty('type', ChildType.Epic);
        expect(formattedChildren[0]).toHaveProperty('pathIdSeparator', PathIdSeparator.Epic);
        expect(formattedChildren[0]).toHaveProperty('fullPath', mockEpic1.group.fullPath);
      });
    });

    describe('extractIssueAssignees', () => {
      it('returns updated assignees array with `edges->node` nesting removed', () => {
        const formattedChildren = epicUtils.extractIssueAssignees(mockIssue1.assignees);

        expect(formattedChildren).toHaveLength(mockIssue1.assignees.edges.length);
        expect(formattedChildren[0]).toHaveProperty(
          'username',
          mockIssue1.assignees.edges[0].node.username,
        );
      });
    });

    describe('extractChildIssues', () => {
      it('returns updated issues array with `type` and `pathIdSeparator` assigned and `edges->node` nesting removed', () => {
        const formattedChildren = epicUtils.extractChildIssues(
          mockQueryResponse2.data.group.epic.issues,
        );

        expect(formattedChildren).toHaveLength(
          mockQueryResponse2.data.group.epic.issues.edges.length,
        );
        expect(formattedChildren[0]).toHaveProperty('type', ChildType.Issue);
        expect(formattedChildren[0]).toHaveProperty('pathIdSeparator', PathIdSeparator.Issue);
      });
    });

    describe('processQueryResponse', () => {
      it('returns array of issues and epics from query response with open epics and issues being on top of the list', () => {
        const formattedChildren = epicUtils.processQueryResponse(mockQueryResponse2.data.group);

        expect(formattedChildren).toHaveLength(5); // 2 Epics and 3 Issues
        expect(formattedChildren[0]).toHaveProperty('type', ChildType.Epic);
        expect(formattedChildren[0]).toHaveProperty('state', 'opened');
        expect(formattedChildren[1]).toHaveProperty('type', ChildType.Issue);
        expect(formattedChildren[1]).toHaveProperty('state', 'opened');
        expect(formattedChildren[2]).toHaveProperty('type', ChildType.Issue);
        expect(formattedChildren[2]).toHaveProperty('state', 'opened');
        expect(formattedChildren[3]).toHaveProperty('type', ChildType.Epic);
        expect(formattedChildren[3]).toHaveProperty('state', 'closed');
        expect(formattedChildren[4]).toHaveProperty('type', ChildType.Issue);
        expect(formattedChildren[4]).toHaveProperty('state', 'closed');
      });
    });
  });
});

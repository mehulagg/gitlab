import { transformBoardConfig } from 'ee/boards/boards_util';

describe('transformBoardConfig', () => {
  beforeEach(() => {
    delete window.location;
  });

  const boardConfig = {
    milestoneTitle: 'milestone',
    assigneeUsername: 'username',
    labels: [
      { id: 5, title: 'Deliverable', color: '#34ebec', type: 'GroupLabel', textColor: '#333333' },
    ],
    weight: 0,
  };

  it('formats url parameters from boardConfig object', () => {
    window.location = { search: '' };
    const result = transformBoardConfig(boardConfig);

    expect(result).toContain(
      'milestone_title=milestone&weight=0&assignee_username=username&label_name[]=Deliverable',
    );
  });

  it('formats url parameters from boardConfig object preventing duplicates with passed filter query', () => {
    window.location = { search: 'label_name[]=Deliverable' };
    const result = transformBoardConfig(boardConfig);

    expect(result).toContain('milestone_title=milestone&weight=0&assignee_username=username');
  });
});

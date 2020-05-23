import {
  calculateJiraImportLabel,
  IMPORT_STATE,
  isFinished,
  isInProgress,
} from '~/jira_import/utils';

describe('isInProgress', () => {
  it.each`
    state                     | result
    ${IMPORT_STATE.SCHEDULED} | ${true}
    ${IMPORT_STATE.STARTED}   | ${true}
    ${IMPORT_STATE.FAILED}    | ${false}
    ${IMPORT_STATE.FINISHED}  | ${false}
    ${IMPORT_STATE.NONE}      | ${false}
    ${undefined}              | ${false}
  `('returns $result when state is $state', ({ state, result }) => {
    expect(isInProgress(state)).toBe(result);
  });
});

describe('isFinished', () => {
  it.each`
    state                     | result
    ${IMPORT_STATE.SCHEDULED} | ${false}
    ${IMPORT_STATE.STARTED}   | ${false}
    ${IMPORT_STATE.FAILED}    | ${false}
    ${IMPORT_STATE.FINISHED}  | ${true}
    ${IMPORT_STATE.NONE}      | ${false}
    ${undefined}              | ${false}
  `('returns $result when state is $state', ({ state, result }) => {
    expect(isFinished(state)).toBe(result);
  });
});

describe('calculateJiraImportLabel', () => {
  const jiraImports = [
    { jiraProjectKey: 'MTG' },
    { jiraProjectKey: 'MJP' },
    { jiraProjectKey: 'MTG' },
    { jiraProjectKey: 'MSJP' },
    { jiraProjectKey: 'MTG' },
  ];

  const labels = [
    { color: '#111', title: 'jira-import::MTG-1' },
    { color: '#222', title: 'jira-import::MTG-2' },
    { color: '#333', title: 'jira-import::MTG-3' },
  ];

  it('returns a label with the Jira project key and correct import count in the title', () => {
    const label = calculateJiraImportLabel(jiraImports, labels);

    expect(label.title).toBe('jira-import::MTG-3');
  });

  it('returns a label with the correct color', () => {
    const label = calculateJiraImportLabel(jiraImports, labels);

    expect(label.color).toBe('#333');
  });
});

import { addIconStatus, formattedTime } from './utils';

export const getTestSuites = (state) => {
  const { test_suites: testSuites = [] } = state.testReports;

  return testSuites.map((suite) => ({
    ...suite,
    formattedTime: formattedTime(suite.total_time),
  }));
};

export const getSelectedSuite = (state) =>
  state.testReports?.test_suites?.[state.selectedSuiteIndex] || {};

export const getSuiteTests = (state) => {
  const { test_cases: testCases = [] } = getSelectedSuite(state);
  const { page, perPage } = state.pageInfo;
  const start = (page - 1) * perPage;

  return testCases
    .map((testCase) => ({
      ...testCase,
      /**
       * filePath is the file string appended onto the blob path.
       * We need to make sure the file string doesn't start with `./` when appending.
       * Even though we could leave the `/` at the beginning, we can't guarantee that the
       * file string will have `/` at the beginning so we should just remove it and add it manually
       */
      filePath: testCase.file ? `${state.blobPath}/${testCase.file.replace(/^\.?\//, '')}` : null,
    }))
    .map(addIconStatus)
    .slice(start, start + perPage);
};

export const getSuiteTestCount = (state) => getSelectedSuite(state)?.test_cases?.length || 0;

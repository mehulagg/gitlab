import initTestCaseList from 'ee/test_case_list/test_case_list_bundle';

document.addEventListener('DOMContentLoaded', () => {
  initTestCaseList({
    mountPointSelector: '#js-test-cases-list',
  });
});

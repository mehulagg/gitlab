import { initTestCaseCreate } from 'ee/test_case_create/test_case_create_bundle';

document.addEventListener('DOMContentLoaded', () => {
  initTestCaseCreate({
    mountPointSelector: '#js-create-test-case',
  });
});

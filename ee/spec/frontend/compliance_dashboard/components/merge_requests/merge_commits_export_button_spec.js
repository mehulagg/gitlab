import { mount, shallowMount } from '@vue/test-utils';
import { GlFormInput, GlForm, GlFormGroup } from '@gitlab/ui';

import MergeCommitsExportButton from 'ee/compliance_dashboard/components/merge_requests/merge_commits_export_button.vue';
import { INPUT_DEBOUNCE } from 'ee/compliance_dashboard/constants';


const VALID_COMMIT_SHA = '92d10c15';
const CSV_EXPORT_PATH = '/merge_commit_reports';
const STRING_OVER_40 = new Array(42).join('a');

describe('MergeCommitsExportButton component', () => {
  let wrapper;

  const findCommitForm = () => wrapper.find(GlForm);
  const findCommitInput = () => wrapper.find(GlFormInput);
  const findCommitInputGroup = () => wrapper.find(GlFormGroup);
  const findCommitInputFeedback = () => wrapper.find('.invalid-feedback');
  const findCommitExportButton = () => wrapper.find('[data-test-id="merge-commit-submit-button"]');
  const findCsvExportButton = () => wrapper.find({ ref: 'listMergeCommitsButton' });

  const createComponent = (mountFn = shallowMount) => {
    return mountFn(MergeCommitsExportButton, {
      propsData: {
        mergeCommitsCsvExportPath: CSV_EXPORT_PATH,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Layout', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('Merge commit CSV export all button', () => {
    beforeEach(() => {
      wrapper = createComponent(mount);
    });

    it('renders the button', () => {
      expect(findCsvExportButton().exists()).toBe(true);
    });

    it('renders the export icon', () => {
      expect(findCsvExportButton().props('icon')).toBe('export');
    });

    it('links to the csv download path', () => {
      expect(findCsvExportButton().attributes('href')).toEqual(CSV_EXPORT_PATH);
    });
  });

  describe('Merge commit custody report', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('renders the form', () => {
      expect(findCommitForm().exists()).toBe(true);
    });

    it('renders the input', () => {
      expect(findCommitInput().exists()).toBe(true);
    });

    it('renders the input label', () => {
      expect(findCommitInputGroup().attributes('label')).toBe('Merge commit SHA');
    });

    it('renders the submit button', () => {
      expect(findCommitExportButton().exists()).toBe(true);
    });

    it('sets a debounce time on the input', () => {
      expect(findCommitInput().attributes('debounce')).toEqual(INPUT_DEBOUNCE.toString());
    });

    it('sets the form action to the csv download path', () => {
      expect(findCommitForm().attributes('action')).toEqual(CSV_EXPORT_PATH);
    });

    it('sets the invalid input feedback message', () => {
      wrapper = createComponent(mount);

      expect(findCommitInputFeedback().text()).toBe('Invalid hash');
    });

    describe.each`
      commitSha           | formError
      ${VALID_COMMIT_SHA} | ${false}
      ${'__aaa'}          | ${true}
      ${'aaa'}            | ${true}
      ${STRING_OVER_40}   | ${true}
    `(`commit hash input validation`, ({ commitSha, formError }) => {
      beforeEach(() => {
        wrapper = createComponent(mount);
        findCommitInput().setValue(commitSha);
        findCommitInput().trigger('blur');
      });

      describe(`when the commit sha is ${commitSha}`, () => {
        it(`${formError ? 'shows' : 'hides'} that the input is invalid`, () => {
          expect(findCommitInputGroup().classes('is-invalid')).toBe(formError);
        });

        it(`${formError ? 'disables' : 'enables'} the submit button`, () => {
          expect(findCommitExportButton().attributes('disabled')).toBe(
            formError ? 'disabled' : undefined,
          );
        });
      });
    });
  });
});

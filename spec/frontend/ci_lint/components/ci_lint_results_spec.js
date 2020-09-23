import { shallowMount, mount } from '@vue/test-utils';
import { GlTable } from '@gitlab/ui';
import CILintResults from '~/ci_lint/components/ci_lint_results.vue';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';
import { mockJobs, mockErrors, mockWarnings } from '../mock_data';

describe('CI Lint Results', () => {
  let wrapper;

  const createComponent = (props = {}, mountFn = shallowMount) => {
    wrapper = mountFn(CILintResults, {
      propsData: {
        valid: true,
        jobs: mockJobs,
        errors: [],
        warnings: [],
        dryRun: false,
        ...props,
      },
    });
  };

  const findTable = () => wrapper.find(GlTable);
  const findErrors = () => wrapper.find('[data-testid="ci-lint-errors"]');
  const findWarnings = () => wrapper.find('[data-testid="ci-lint-warnings"]');
  const findStatus = () => wrapper.find('[data-testid="ci-lint-status"]');
  const findOnlyExcept = () => wrapper.find('[data-testid="ci-lint-only-except"]');
  const findLintJobs = () => wrapper.findAll('[data-testid="ci-lint-job-name"]');
  const findBeforeScripts = () => wrapper.findAll('[data-testid="ci-lint-before-script"]');
  const findAfterScripts = () => wrapper.findAll('[data-testid="ci-lint-after-script"]');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('Invalid results', () => {
    beforeEach(() => {
      createComponent({ valid: false, errors: mockErrors, warnings: mockWarnings });
    });

    it('does not display the table', () => {
      expect(findTable().exists()).toBe(false);
    });

    it('displays the invalid status', () => {
      expect(findStatus().text()).toBe(wrapper.vm.$options.incorrect.text);
      expect(findStatus().props('variant')).toBe(wrapper.vm.$options.incorrect.variant);
    });

    it('displays the error message', () => {
      const [expectedError] = mockErrors;

      expect(findErrors().text()).toBe(expectedError);
    });

    it('displays the warning message', () => {
      const [foundWarning] = findWarnings().props('warnings');
      const [expectedWarning] = mockWarnings;

      expect(foundWarning).toBe(expectedWarning);
    });
  });

  describe('Valid results', () => {
    beforeEach(() => {
      createComponent();
    });

    it('displays table', () => {
      expect(findTable().exists()).toBe(true);
    });

    it('displays the valid status', () => {
      expect(findStatus().text()).toBe(wrapper.vm.$options.correct.text);
      expect(findStatus().props('variant')).toBe(wrapper.vm.$options.correct.variant);
    });

    it('does not display only/expect values with dry run', () => {
      expect(findOnlyExcept().exists()).toBe(false);
    });
  });

  describe('Lint results', () => {
    beforeEach(() => {
      createComponent({}, mount);
    });

    it('formats parameter value', () => {
      findLintJobs().wrappers.forEach((job, index) => {
        const { stage } = mockJobs[index];
        const { name } = mockJobs[index];

        expect(job.text()).toBe(`${capitalizeFirstCharacter(stage)} Job - ${name}`);
      });
    });

    it('only shows before scripts when data is present', () => {
      const beforeScripts = [mockJobs.find(job => job.before_script.length !== 0)];
      expect(findBeforeScripts()).toHaveLength(beforeScripts.length);
    });

    it('only shows after script when data is present', () => {
      const afterScripts = [mockJobs.find(job => job.after_script.length !== 0)];
      expect(findAfterScripts()).toHaveLength(afterScripts.length);
    });
  });
});

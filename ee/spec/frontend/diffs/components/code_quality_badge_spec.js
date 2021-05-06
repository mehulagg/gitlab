import { GlBadge } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CodeQualityBadge from 'ee/diffs/components/code_quality_badge.vue';
import CodequalityIssueBody from '~/reports/codequality_report/components/codequality_issue_body.vue';

describe('EE CodeQualityBadge', () => {
  let wrapper;

  const props = {
    fileName: 'index.js',
    codequalityDiff: [
      {
        severity: 'major',
        description:
          'Function `aVeryLongFunction` has 52 lines of code (exceeds 25 allowed). Consider refactoring.',
      },
      {
        severity: 'minor',
        description: 'Arrow function has too many statements (52). Maximum allowed is 30.',
      },
    ],
  };

  beforeEach(() => {
    wrapper = shallowMount(CodeQualityBadge, {
      propsData: props,
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('opens a code quality details modal on click', () => {
    const modalId = 'codequality-details-index.js';
    const rootEmit = jest.spyOn(wrapper.vm.$root, '$emit');
    wrapper.findComponent(GlBadge).trigger('click');

    expect(rootEmit.mock.calls[0]).toContainEqual(modalId);
  });

  it('passes the issue data into the issue components correctly', () => {
    const issueProps = wrapper
      .findAllComponents(CodequalityIssueBody)
      .wrappers.map((w) => w.props());

    expect(issueProps).toEqual([
      {
        issue: {
          path: props.fileName,
          severity: props.codequalityDiff[0].severity,
          name: props.codequalityDiff[0].description,
        },
        status: 'neutral',
      },
      {
        issue: {
          path: props.fileName,
          severity: props.codequalityDiff[1].severity,
          name: props.codequalityDiff[1].description,
        },
        status: 'neutral',
      },
    ]);
  });
});

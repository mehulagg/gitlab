import { waitFor } from '@testing-library/dom';
import { TEST_HOST } from 'helpers/test_constants';
import initDiffsApp from '~/diffs';
import { createStore } from '~/mr_notes/stores';
import {
  getDiffCodePart,
  getLineNumberFromCodeElement,
  getCodeElementFromLineNumber,
} from './diffs_interopability_api';

jest.mock('~/vue_shared/mixins/gl_feature_flags_mixin', () => () => ({
  inject: {
    glFeatures: {
      from: 'window.gon.features',
      default: () => global.window.gon?.features,
    },
  },
}));

const TEST_PROJECT_PATH = 'gitlab-org/gitlab-test';
const TEST_BASE_URL = `/${TEST_PROJECT_PATH}/-/merge_requests/1/`;
const TEST_DIFF_FILE = 'files/js/commit.coffee';
const EXPECT_INLINE = [
  ['head', 1],
  ['head', 2],
  ['head', 3],
  ['base', 4],
  ['head', 4],
  null,
  ['base', 6],
  ['head', 6],
  null,
];
const EXPECT_PARALLEL_LEFT_SIDE = [
  ['base', 1],
  ['base', 2],
  ['base', 3],
  ['base', 4],
  null,
  ['base', 6],
  null,
];
const EXPECT_PARALLEL_RIGHT_SIDE = [
  ['head', 1],
  ['head', 2],
  ['head', 3],
  ['head', 4],
  null,
  ['head', 6],
  null,
];

const startDiffsApp = () => {
  const el = document.createElement('div');
  el.id = 'js-diffs-app';
  document.body.appendChild(el);
  Object.assign(el.dataset, {
    endpoint: TEST_BASE_URL,
    endpointMetadata: `${TEST_BASE_URL}diffs_metadata.json`,
    endpointBatch: `${TEST_BASE_URL}diffs_batch.json`,
    projectPath: TEST_PROJECT_PATH,
    helpPagePath: '/help',
    currentUserData: 'null',
    changesEmptyStateIllustration: '',
    isFluidLayout: 'false',
    dismissEndpoint: '',
    showSuggestPopover: 'false',
    showWhitespaceDefault: 'true',
    viewDiffsFileByFile: 'false',
    defaultSuggestionCommitMessage: 'Lorem ipsum',
  });

  const store = createStore();

  const vm = initDiffsApp(store);

  store.dispatch('setActiveTab', 'diffs');

  return vm;
};

describe('diffs third party interoperability', () => {
  let vm;

  afterEach(() => {
    vm.$destroy();
    document.body.innerHTML = '';
  });

  const tryOrErrorMessage = (fn) => (...args) => {
    try {
      return fn(...args);
    } catch (e) {
      return e.message;
    }
  };

  const findDiffFile = () => document.querySelector(`.diff-file[data-path="${TEST_DIFF_FILE}"]`);
  const hasLines = (sel = 'tr.line_holder') => findDiffFile().querySelectorAll(sel).length > 0;
  const findLineElements = (sel = 'tr.line_holder') =>
    Array.from(findDiffFile().querySelectorAll(sel));

  const findCodeElements = (lines, sel = 'td.line_content') => {
    return lines.map((x) => x.querySelector(`${sel} span.line`));
  };

  const getCodeElementsInteropModel = (codeElements) =>
    codeElements.map(
      (x) =>
        x && [
          tryOrErrorMessage(getDiffCodePart)(x),
          tryOrErrorMessage(getLineNumberFromCodeElement)(x),
        ],
    );

  describe.each`
    desc                          | unifiedDiffComponents | view          | rowSelector               | codeSelector                          | expectation
    ${'inline view'}              | ${false}              | ${'inline'}   | ${'tr.line_holder'}       | ${'td.line_content'}                  | ${EXPECT_INLINE}
    ${'parallel view left side'}  | ${false}              | ${'parallel'} | ${'tr.line_holder'}       | ${'td.line_content.left-side'}        | ${EXPECT_PARALLEL_LEFT_SIDE}
    ${'parallel view right side'} | ${false}              | ${'parallel'} | ${'tr.line_holder'}       | ${'td.line_content.right-side'}       | ${EXPECT_PARALLEL_RIGHT_SIDE}
    ${'inline view'}              | ${true}               | ${'inline'}   | ${'.diff-tr.line_holder'} | ${'.diff-td.line_content'}            | ${EXPECT_INLINE}
    ${'parallel view left side'}  | ${true}               | ${'parallel'} | ${'.diff-tr.line_holder'} | ${'.diff-td.line_content.left-side'}  | ${EXPECT_PARALLEL_LEFT_SIDE}
    ${'parallel view right side'} | ${true}               | ${'parallel'} | ${'.diff-tr.line_holder'} | ${'.diff-td.line_content.right-side'} | ${EXPECT_PARALLEL_RIGHT_SIDE}
  `(
    '$desc (unifiedDiffComponents=$unifiedDiffComponents)',
    ({ unifiedDiffComponents, view, rowSelector, codeSelector, expectation }) => {
      beforeEach(async () => {
        global.jsdom.reconfigure({
          url: `${TEST_HOST}/${TEST_BASE_URL}/diffs?view=${view}`,
        });
        window.gon.features = { unifiedDiffComponents };

        vm = startDiffsApp();

        await waitFor(() => expect(hasLines(rowSelector)).toBe(true));
      });

      it('should match diff model', () => {
        const lines = findLineElements(rowSelector);
        const codes = findCodeElements(lines, codeSelector);

        expect(getCodeElementsInteropModel(codes)).toEqual(expectation);
      });

      it.each`
        lineNumber | part      | expectedText
        ${4}       | ${'base'} | ${'new CommitFile(this)'}
        ${4}       | ${'head'} | ${'new CommitFile(@)'}
        ${2}       | ${'base'} | ${'constructor: ->'}
        ${2}       | ${'head'} | ${'constructor: ->'}
      `(
        'should find code element lineNumber=$lineNumber part=$part',
        ({ lineNumber, part, expectedText }) => {
          const codeElement = getCodeElementFromLineNumber(findDiffFile(), lineNumber, part);

          expect(codeElement.textContent.trim()).toBe(expectedText);
        },
      );
    },
  );
});

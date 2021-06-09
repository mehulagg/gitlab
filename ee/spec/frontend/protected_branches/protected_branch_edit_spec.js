import MockAdapter from 'axios-mock-adapter';
import $ from 'jquery';
import { TEST_HOST } from 'helpers/test_constants';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import ProtectedBranchEdit from '~/protected_branches/protected_branch_edit';

jest.mock('~/flash');

const TEST_URL = `${TEST_HOST}/url`;
const IS_CHECKED_CLASS = 'is-checked';

describe('EE ProtectedBranchEdit', () => {
  let mock;

  beforeEach(() => {
    setFixtures(`<div id="wrap" data-url="${TEST_URL}">
      <button class="js-code-owner-toggle">Toggle</button>
    </div>`);

    jest.spyOn(ProtectedBranchEdit.prototype, 'buildDropdowns').mockImplementation();

    mock = new MockAdapter(axios);
  });

  const findCodeOwnerToggle = () => document.querySelector('.js-code-owner-toggle');

  const create = ({ isChecked = false }) => {
    if (isChecked) {
      findCodeOwnerToggle().classList.add(IS_CHECKED_CLASS);
    }

    return new ProtectedBranchEdit({ $wrap: $('#wrap'), hasLicense: true });
  };

  afterEach(() => {
    mock.restore();
  });

  describe('when unchecked toggle button', () => {
    let toggle;

    beforeEach(() => {
      create({ isChecked: false });

      toggle = findCodeOwnerToggle();
    });

    it('is not changed', () => {
      expect(toggle).not.toHaveClass(IS_CHECKED_CLASS);
      expect(toggle).not.toBeDisabled();
    });

    describe('when clicked', () => {
      beforeEach(() => {
        mock
          .onPatch(TEST_URL, { protected_branch: { code_owner_approval_required: true } })
          .replyOnce(200, {});

        toggle.click();
      });

      it('checks and disables button', () => {
        expect(toggle).toHaveClass(IS_CHECKED_CLASS);
        expect(toggle).toBeDisabled();
      });

      it('sends update to BE', () =>
        axios.waitForAll().then(() => {
          // Args are asserted in the `.onPatch` call
          expect(mock.history.patch).toHaveLength(1);

          expect(toggle).not.toBeDisabled();
          expect(createFlash).not.toHaveBeenCalled();
        }));
    });

    describe('when clicked and BE error', () => {
      beforeEach(() => {
        mock.onPatch(TEST_URL).replyOnce(500);
        toggle.click();
      });

      it('flashes error', () =>
        axios.waitForAll().then(() => {
          expect(createFlash).toHaveBeenCalled();
        }));
    });
  });
});

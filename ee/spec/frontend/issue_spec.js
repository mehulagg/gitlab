/* eslint-disable one-var */

import MockAdapter from 'axios-mock-adapter';
import $ from 'jquery';
import Issue from '~/issue';
import axios from '~/lib/utils/axios_utils';
import '~/lib/utils/text_utility';

describe('Issue', () => {
  let testContext;

  beforeEach(() => {
    testContext = {};
  });

  let $btn, $dropdown, $alert, $boxOpen, $boxClosed;

  preloadFixtures('ee/issues/blocked-issue.html');

  describe('with blocked issue', () => {
    let mock;

    function setup() {
      testContext.issue = new Issue();

      testContext.$projectIssuesCounter = $('.issue_counter').first();
      testContext.$projectIssuesCounter.text('1,001');
    }

    function mockCloseButtonResponseSuccess(url, response) {
      mock.onPut(url).reply(() => [200, response]);
    }

    beforeEach(() => {
      loadFixtures('ee/issues/blocked-issue.html');

      mock = new MockAdapter(axios);
      mock.onGet(/(.*)\/related_branches$/).reply(200, {});
      jest.spyOn(axios, 'get');
    });

    afterEach(() => {
      mock.restore();
    });

    it(`displays warning when attempting to close the issue`, done => {
      setup();

      $btn = $('.js-issuable-close-button');
      $dropdown = $('.js-issuable-close-dropdown ');
      $alert = $('.js-close-blocked-issue-warning');

      expect($btn).toExist();
      expect($btn).toHaveClass('btn-issue-blocked');
      expect($dropdown).not.toHaveClass('hidden');
      expect($alert).toHaveClass('hidden');

      testContext.$triggeredButton = $btn;
      testContext.$triggeredButton.trigger('click');

      setImmediate(() => {
        expect($alert).not.toHaveClass('hidden');
        expect($dropdown).toHaveClass('hidden');

        done();
      });
    });

    it(`hides warning when cancelling closing the issue`, done => {
      setup();

      $btn = $('.js-issuable-close-button');
      $alert = $('.js-close-blocked-issue-warning');

      testContext.$triggeredButton = $btn;
      testContext.$triggeredButton.trigger('click');

      setImmediate(() => {
        expect($alert).not.toHaveClass('hidden');

        const $cancelbtn = $('.js-close-blocked-issue-warning .js-cancel-blocked-issue-warning');
        $cancelbtn.trigger('click');

        expect($alert).toHaveClass('hidden');

        done();
      });
    });

    it('closes the issue when clicking alert close button', done => {
      $btn = $('.js-issuable-close-button');
      $boxOpen = $('div.status-box-open');
      $boxClosed = $('div.status-box-issue-closed');

      expect($boxOpen).not.toHaveClass('hidden');
      expect($boxOpen).toHaveText('Open');
      expect($boxClosed).toHaveClass('hidden');

      testContext.$triggeredButton = $btn;

      mockCloseButtonResponseSuccess(testContext.$triggeredButton.data('endpoint'), {
        id: 34,
      });

      setup();
      testContext.$triggeredButton.trigger('click');

      const $btnCloseAnyway = $('.js-close-blocked-issue-warning .btn-close-anyway');
      $btnCloseAnyway.trigger('click');

      setImmediate(() => {
        expect($btn).toHaveText('Reopen');
        expect($boxOpen).toHaveClass('hidden');
        expect($boxClosed).not.toHaveClass('hidden');
        expect($boxClosed).toHaveText('Closed');

        done();
      });
    });
  });
});

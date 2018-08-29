import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import renderNotebook from '~/blob/notebook';

describe('iPython notebook renderer', () => {
  let mock;
  let vm;

  preloadFixtures('static/notebook_viewer.html.raw');

  beforeEach(() => {
    loadFixtures('static/notebook_viewer.html.raw');
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    vm.$destroy();
    mock.restore();
  });

  it('shows loading icon', () => {
    vm = renderNotebook();

    expect(
      document.querySelector('.loading'),
    ).not.toBeNull();
  });

  describe('successful response', () => {
    beforeEach((done) => {
      mock.onGet('/test').reply(200, {
        cells: [{
          cell_type: 'markdown',
          source: ['# test'],
        }, {
          cell_type: 'code',
          execution_count: 1,
          source: [
            'def test(str)',
            '  return str',
          ],
          outputs: [],
        }],
      });

      vm = renderNotebook();

      setTimeout(() => {
        done();
      });
    });

    it('does not show loading icon', () => {
      expect(
        document.querySelector('.loading'),
      ).toBeNull();
    });

    it('renders the notebook', () => {
      expect(
        document.querySelector('.md'),
      ).not.toBeNull();
    });

    it('renders the markdown cell', () => {
      expect(
        document.querySelector('h1'),
      ).not.toBeNull();

      expect(
        document.querySelector('h1').textContent.trim(),
      ).toBe('test');
    });

    it('highlights code', () => {
      expect(
        document.querySelector('.token'),
      ).not.toBeNull();

      expect(
        document.querySelector('.language-python'),
      ).not.toBeNull();
    });
  });

  describe('error in JSON response', () => {
    beforeEach(done => {
      mock
        .onGet('/test')
        .reply(() =>
          // eslint-disable-next-line prefer-promise-reject-errors
          Promise.reject({ status: 200, data: '{ "cells": [{"cell_type": "markdown"} }' }),
        );

      vm = renderNotebook();

      setTimeout(() => {
        done();
      });
    });

    it('does not show loading icon', () => {
      expect(
        document.querySelector('.loading'),
      ).toBeNull();
    });

    it('shows error message', () => {
      expect(
        document.querySelector('.md').textContent.trim(),
      ).toBe('An error occurred whilst parsing the file.');
    });
  });

  describe('error getting file', () => {
    beforeEach((done) => {
      mock.onGet('/test').reply(500, '');

      vm = renderNotebook();

      setTimeout(() => {
        done();
      });
    });


    it('does not show loading icon', () => {
      expect(
        document.querySelector('.loading'),
      ).toBeNull();
    });

    it('shows error message', () => {
      expect(
        document.querySelector('.md').textContent.trim(),
      ).toBe('An error occurred whilst loading the file. Please try again later.');
    });
  });
});

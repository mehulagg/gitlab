import GfmAutoCompleteEE from 'ee/gfm_auto_complete';
import $ from 'jquery';
import { TEST_HOST } from 'jest/helpers/test_constants';

describe('GfmAutoCompleteEE', () => {
  const dataSources = {
    labels: `${TEST_HOST}/autocomplete_sources/labels`,
  };
  let instance;
  const $input = $('<input type="text" />');

  beforeEach(() => {
    instance = new GfmAutoCompleteEE(dataSources);
    instance.setup($input);
  });

  it('should have enableMap', () => {
    expect(instance.enableMap).not.toBeNull();
  });
});

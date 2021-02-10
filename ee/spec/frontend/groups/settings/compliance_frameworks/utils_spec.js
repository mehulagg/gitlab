import httpStatus from '~/lib/utils/http_status';
import * as Utils from 'ee/groups/settings/compliance_frameworks/utils';
import Api from '~/api';

describe('Utils', () => {
  describe('initialiseFormData', () => {
    it('returns the initial form data object', () => {
      expect(Utils.initialiseFormData()).toStrictEqual({
        name: null,
        description: null,
        pipelineConfigurationFullPath: null,
        color: null,
      });
    });
  });

  describe('getPipelineConfigurationPathParts', () => {
    it.each`
      path                 | parts
      ${''}                | ${{}}
      ${'abc'}             | ${{}}
      ${'foo@bar/baz'}     | ${{}}
      ${'foo.pdf@bar/baz'} | ${{}}
      ${'foo.yml@bar/baz'} | ${{ file: 'foo.yml', group: 'bar', project: 'baz' }}
    `('should return the correct object when $path is given', ({ path, parts }) => {
      expect(Utils.getPipelineConfigurationPathParts(path)).toStrictEqual(parts);
    });
  });

  describe('isValidPipelineConfigurationFormat', () => {
    it.each`
      path                 | valid
      ${null}              | ${false}
      ${''}                | ${false}
      ${'abc'}             | ${false}
      ${'foo@bar/baz'}     | ${false}
      ${'foo.pdf@bar/baz'} | ${false}
      ${'foo.yml@bar/baz'} | ${true}
    `('should validate to $valid when path is $path', ({ path, valid }) => {
      expect(Utils.isValidPipelineConfigurationFormat(path)).toBe(valid);
    });
  });

  describe('checkPipelineConfigurationFileExists', () => {
    it.each`
      response                 | returns
      ${httpStatus.OK}         | ${true}
      ${httpStatus.NO_CONTENT} | ${false}
      ${httpStatus.NOT_FOUND}  | ${false}
    `('should return $returns when the response is $response', async ({ response, returns }) => {
      if (response === httpStatus.NOT_FOUND) {
        jest.spyOn(Api, 'getRawFile').mockRejectedValueOnce({ status: response });
      } else {
        jest.spyOn(Api, 'getRawFile').mockReturnValueOnce({ status: response });
      }

      expect(await Utils.checkPipelineConfigurationFileExists('foo', 'bar', 'baz')).toBe(returns);
    });
  });
});

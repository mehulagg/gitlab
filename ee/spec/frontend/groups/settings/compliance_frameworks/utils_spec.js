import * as Utils from 'ee/groups/settings/compliance_frameworks/utils';

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
});

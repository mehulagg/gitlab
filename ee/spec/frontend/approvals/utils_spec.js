import * as Utils from 'ee/approvals/utils';

describe('Utils', () => {
  describe('joinRuleResponses', () => {
    it('should join multiple response objects and concatenate the rules array of all objects', () => {
      const resX = { foo: 'bar', rules: [1, 2, 3] };
      const resY = { foo: 'something', rules: [4, 5] };

      expect(Utils.joinRuleResponses([resX, resY])).toStrictEqual({
        foo: 'something',
        rules: [1, 2, 3, 4, 5],
      });
    });
  });
});

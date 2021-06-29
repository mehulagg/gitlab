import * as constants from 'ee/billings/constants'

describe('constants', () => {
  describe('DAYS_FOR_RENEWAL', () => {
    it('returns days needed before enable renewal', () => {
      expect(constants.DAYS_FOR_RENEWAL).toEqual(15)
    })
  })
});

import IssuableFilteredSearchTokenKeys from 'ee/filtered_search/issuable_filtered_search_token_keys';

describe('Issues Filtered Search Token Keys (EE)', () => {
  const weightTokenKey = {
    formattedKey: 'Weight',
    key: 'weight',
    type: 'string',
    param: '',
    symbol: '',
    icon: 'weight',
    tag: 'number',
  };

  describe('get', () => {
    let tokenKeys;

    beforeEach(() => {
      IssuableFilteredSearchTokenKeys.enableMultipleAssignees();
      tokenKeys = IssuableFilteredSearchTokenKeys.get();
    });

    it('should return weightTokenKey as part of tokenKeys', () => {
      const match = tokenKeys.find((tk) => tk.key === weightTokenKey.key);

      expect(match).toEqual(weightTokenKey);
    });

    it('should return assignee as an array', () => {
      const assignee = tokenKeys.find((tokenKey) => tokenKey.key === 'assignee');

      expect(assignee.type).toBe('array');
    });
  });

  describe('getConditions', () => {
    let conditions;

    beforeEach(() => {
      conditions = IssuableFilteredSearchTokenKeys.getConditions();
    });

    it('should return weightConditions as part of conditions', () => {
      const weightConditions = conditions.filter((c) => c.tokenKey === 'weight');

      expect(weightConditions).toHaveLength(4);
    });
  });

  describe('searchByKey', () => {
    it('should return weight tokenKey when found by weight key', () => {
      const tokenKeys = IssuableFilteredSearchTokenKeys.get();
      const match = tokenKeys.find((tk) => tk.key === weightTokenKey.key);
      const result = IssuableFilteredSearchTokenKeys.searchByKey(weightTokenKey.key);

      expect(result).toEqual(match);
    });
  });

  describe('searchBySymbol', () => {
    it('should return weight tokenKey when found by weight symbol', () => {
      const tokenKeys = IssuableFilteredSearchTokenKeys.get();
      const match = tokenKeys.find((tk) => tk.symbol === weightTokenKey.symbol);
      const result = IssuableFilteredSearchTokenKeys.searchBySymbol(weightTokenKey.symbol);

      expect(result).toEqual(match);
    });
  });

  describe('searchByKeyParam', () => {
    it('should return weight tokenKey when found by weight key param', () => {
      const tokenKeys = IssuableFilteredSearchTokenKeys.get();
      const match = tokenKeys.find((tk) => tk.key === weightTokenKey.key);
      const result = IssuableFilteredSearchTokenKeys.searchByKeyParam(weightTokenKey.key);

      expect(result).toEqual(match);
    });
  });

  describe('searchByConditionUrl', () => {
    it('should return weight condition when found by weight url', () => {
      const conditions = IssuableFilteredSearchTokenKeys.getConditions();
      const weightConditions = conditions.filter((c) => c.tokenKey === 'weight');
      const result = IssuableFilteredSearchTokenKeys.searchByConditionUrl(weightConditions[0].url);

      expect(result).toBe(weightConditions[0]);
    });
  });

  describe('searchByConditionKeyValue', () => {
    it('should return weight condition when found by weight tokenKey and value', () => {
      const conditions = IssuableFilteredSearchTokenKeys.getConditions();
      const weightConditions = conditions.filter((c) => c.tokenKey === 'weight');
      const result = IssuableFilteredSearchTokenKeys.searchByConditionKeyValue(
        weightConditions[0].tokenKey,
        weightConditions[0].operator,
        weightConditions[0].value,
      );

      expect(result).toEqual(weightConditions[0]);
    });
  });
});

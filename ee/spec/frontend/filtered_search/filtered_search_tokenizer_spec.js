import IssuableFilteredSearchTokenKeys from 'ee/filtered_search/issuable_filtered_search_token_keys';
import FilteredSearchTokenizer from '~/filtered_search/filtered_search_tokenizer';

describe('Filtered Search Tokenizer', () => {
  const allowedKeys = IssuableFilteredSearchTokenKeys.getKeys();

  describe('processTokens', () => {
    describe('epic tokens', () => {
      it.each`
        searchQuery     | operator
        ${'epic:=&36'}  | ${'='}
        ${'epic:!=&36'} | ${'!='}
      `('returns for input containing $searchQuery', ({ searchQuery, operator }) => {
        const results = FilteredSearchTokenizer.processTokens(searchQuery, allowedKeys);

        expect(results.searchToken).toBe('');
        expect(results.tokens).toHaveLength(1);
        expect(results.tokens[0].key).toBe('epic');
        expect(results.tokens[0].operator).toBe(operator);
        expect(results.tokens[0].symbol).toBe('&');
        expect(results.tokens[0].value).toBe('36');
      });

      it('returns for input containing string values', () => {
        const results = FilteredSearchTokenizer.processTokens('epic:=any', allowedKeys);

        expect(results.searchToken).toBe('');
        expect(results.tokens).toHaveLength(1);
        expect(results.tokens[0].key).toBe('epic');
        expect(results.tokens[0].operator).toBe('=');
        expect(results.tokens[0].symbol).toBe('');
        expect(results.tokens[0].value).toBe('any');
      });
    });
  });
});

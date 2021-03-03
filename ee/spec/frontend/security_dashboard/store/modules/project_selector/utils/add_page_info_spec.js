import addPageInfo from 'ee/security_dashboard/store/modules/project_selector/utils/add_page_info';

describe('EE Project Selector store utils', () => {
  describe('addPageInfo', () => {
    it('takes an API response and adds a "pageInfo" property that contains the headers pagination data', () => {
      const responseData = {
        data: { foo: 'bar ' },
        headers: {
          'X-Next-Page': 0,
          'X-Page': 0,
          'X-Total': 0,
          'X-Total-Pages': 0,
        },
      };

      const responseDataWithPageInfo = addPageInfo(responseData);

      expect(responseDataWithPageInfo).toStrictEqual({
        ...responseData,
        pageInfo: {
          page: 0,
          nextPage: 0,
          total: 0,
          totalPages: 0,
        },
      });
    });

    it.each([{}, { foo: 'foo' }, null, undefined, false])(
      'returns the original input if it does not contain a header property',
      (input) => {
        expect(addPageInfo(input)).toBe(input);
      },
    );
  });
});

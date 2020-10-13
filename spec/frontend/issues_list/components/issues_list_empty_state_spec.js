describe.only('with empty issues response', () => {
    beforeEach(() => {
      setupApiMock(() => [200, []]);
    });

    describe('with query in window location', () => {
      beforeEach(() => {
        window.location.search = '?weight=Any';

        factory();

        return waitForPromises().then(() => wrapper.vm.$nextTick());
      });

      it('should display "Sorry, your filter produced no results" if filters are too specific', () => {
        expect(findEmptyState().props('title')).toMatchSnapshot();
      });
    });

    describe('with closed state', () => {
      beforeEach(() => {
        window.location.search = '?state=closed';

        factory();

        return waitForPromises().then(() => wrapper.vm.$nextTick());
      });

      it('should display a message "There are no closed issues" if there are no closed issues', () => {
        expect(findEmptyState().props('title')).toMatchSnapshot();
      });
    });

    describe('with all state', () => {
      beforeEach(() => {
        window.location.search = '?state=all';

        factory();

        return waitForPromises().then(() => wrapper.vm.$nextTick());
      });

      it('should display a catch-all if there are no issues to show', () => {
        expect(findEmptyState().element).toMatchSnapshot();
      });
    });

    describe('with empty query', () => {
      beforeEach(() => {
        factory();

        return wrapper.vm.$nextTick().then(waitForPromises);
      });

      it('should display the message "There are no open issues"', () => {
        expect(findEmptyState().props('title')).toMatchSnapshot();
      });
    });
  });
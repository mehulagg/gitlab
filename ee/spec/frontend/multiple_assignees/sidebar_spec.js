describe('Sidebar', () => {
  preloadFixtures('issues/open-issue.html');

  beforeEach(() => loadFixtures('issues/open-issue.html'));

  it('does not have a max select', () => {
    const dropdown = document.querySelector('.js-author-search');

    expect(dropdown.dataset.maxSelect).toBeUndefined();
  });
});

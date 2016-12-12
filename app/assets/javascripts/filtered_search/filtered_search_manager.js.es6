/* eslint-disable no-param-reassign */
((global) => {
  // TODO: Encapsulate inside class?
  function toggleClearSearchButton(e) {
    const clearSearchButton = document.querySelector('.clear-search');

    if (e.target.value) {
      clearSearchButton.classList.remove('hidden');
    } else {
      clearSearchButton.classList.add('hidden');
    }
  }

  function loadSearchParamsFromURL() {
    // We can trust that each param has one & since values containing & will be encoded
    // Remove the first character of search as it is always ?
    const params = window.location.search.slice(1).split('&');
    let inputValue = '';

    params.forEach((p) => {
      const split = p.split('=');
      const key = decodeURIComponent(split[0]);
      const value = split[1];

      // Check if it matches edge conditions listed in gl.FilteredSearchTokenKeys.get()
      let conditionIndex = 0;
      const validCondition = gl.FilteredSearchTokenKeys.get()
        .filter(v => v.conditions && v.conditions.filter((c, index) => {
          // Return TokenKeys that have conditions that much the URL
          if (c.url === p) {
            conditionIndex = index;
          }
          return c.url === p;
        })[0])[0];

      if (validCondition) {
        // Parse params based on rules provided in the conditions key of gl.FilteredSearchTokenKeys.get()
        inputValue += `${validCondition.key}:${validCondition.conditions[conditionIndex].keyword}`;
        inputValue += ' ';
      } else {
        // Sanitize value since URL converts spaces into +
        // Replace before decode so that we know what was originally + versus the encoded +
        const sanitizedValue = value ? decodeURIComponent(value.replace(/[+]/g, ' ')) : value;
        const match = gl.FilteredSearchTokenKeys.get().filter(t => key === `${t.key}_${t.param}`)[0];

        if (match) {
          const sanitizedKey = key.slice(0, key.indexOf('_'));
          const valueHasSpace = sanitizedValue.indexOf(' ') !== -1;
          const symbol = match.symbol;

          const preferredQuotations = '"';
          let quotationsToUse = preferredQuotations;

          if (valueHasSpace) {
            // Prefer ", but use ' if required
            quotationsToUse = sanitizedValue.indexOf(preferredQuotations) === -1 ? preferredQuotations : '\'';
          }

          inputValue += valueHasSpace ? `${sanitizedKey}:${symbol}${quotationsToUse}${sanitizedValue}${quotationsToUse}` : `${sanitizedKey}:${symbol}${sanitizedValue}`;
          inputValue += ' ';
        } else if (!match && key === 'search') {
          inputValue += sanitizedValue;
          inputValue += ' ';
        }
      }
    });

    // Trim the last space value
    document.querySelector('.filtered-search').value = inputValue.trim();

    if (inputValue.trim()) {
      document.querySelector('.clear-search').classList.remove('hidden');
    }
  }

  class FilteredSearchManager {
    constructor() {
      this.tokenizer = gl.FilteredSearchTokenizer;
      this.filteredSearchInput = document.querySelector('.filtered-search');
      this.clearSearchButton = document.querySelector('.clear-search');
      this.dropdownManager = new gl.FilteredSearchDropdownManager();

      this.bindEvents();
      loadSearchParamsFromURL();
      this.dropdownManager.setDropdown();

      this.cleanupWrapper = this.cleanup.bind(this);
      document.addEventListener('page:fetch', this.cleanupWrapper);
    }

    cleanup() {
      this.unbindEvents();
      document.removeEventListener('page:fetch', this.cleanupWrapper);
    }

    bindEvents() {
      this.setDropdownWrapper = this.dropdownManager.setDropdown.bind(this.dropdownManager);
      this.checkForEnterWrapper = this.checkForEnter.bind(this);
      this.clearSearchWrapper = this.clearSearch.bind(this);
      this.checkForBackspaceWrapper = this.checkForBackspace.bind(this);

      this.filteredSearchInput.addEventListener('input', this.setDropdownWrapper);
      this.filteredSearchInput.addEventListener('input', toggleClearSearchButton);
      this.filteredSearchInput.addEventListener('keydown', this.checkForEnterWrapper);
      this.filteredSearchInput.addEventListener('keyup', this.checkForBackspaceWrapper);
      this.clearSearchButton.addEventListener('click', this.clearSearchWrapper);
    }

    unbindEvents() {
      this.filteredSearchInput.removeEventListener('input', this.setDropdownWrapper);
      this.filteredSearchInput.removeEventListener('input', toggleClearSearchButton);
      this.filteredSearchInput.removeEventListener('keydown', this.checkForEnterWrapper);
      this.filteredSearchInput.removeEventListener('keyup', this.checkForBackspaceWrapper);
      this.clearSearchButton.removeEventListener('click', this.clearSearchWrapper);
    }

    clearSearch(e) {
      e.stopPropagation();
      e.preventDefault();

      this.filteredSearchInput.value = '';
      this.clearSearchButton.classList.add('hidden');

      this.dropdownManager.resetDropdowns();
    }

    checkForBackspace(e) {
      // 8 = Backspace Key
      // 46 = Delete Key
      if (e.keyCode === 8 || e.keyCode === 46) {
        // Reposition dropdown so that it is aligned with cursor
        this.dropdownManager.updateCurrentDropdownOffset();
      }
    }

    checkForEnter(e) {
      if (e.keyCode === 13) {
        e.stopPropagation();
        e.preventDefault();

        // Prevent droplab from opening dropdown
        this.dropdownManager.destroyDroplab();

        this.search();
      }
    }

    search() {
      let path = '?scope=all&utf8=✓';

      // Check current state
      const currentPath = window.location.search;
      const stateIndex = currentPath.indexOf('state=');
      const defaultState = 'opened';
      let currentState = defaultState;

      const { tokens, searchToken } = this.tokenizer.processTokens(this.filteredSearchInput.value);

      if (stateIndex !== -1) {
        // Get currentState from url params if available
        const remaining = currentPath.slice(stateIndex + 'state='.length);
        const separatorIndex = remaining.indexOf('&');

        currentState = separatorIndex === -1 ? remaining : remaining.slice(0, separatorIndex);
      }

      path += `&state=${currentState}`;
      tokens.forEach((token) => {
        const match = gl.FilteredSearchTokenKeys.get().filter(t => t.key === token.key)[0];
        let tokenPath = '';

        if (token.wildcard && match.conditions) {
          const condition = match.conditions
            .filter(c => c.keyword === token.value.toLowerCase())[0];

          if (condition) {
            tokenPath = `${condition.url}`;
          }
        } else if (!token.wildcard) {
          // Remove the wildcard token
          tokenPath = `${token.key}_${match.param}=${encodeURIComponent(token.value.slice(1))}`;
        } else {
          tokenPath = `${token.key}_${match.param}=${encodeURIComponent(token.value)}`;
        }

        path += `&${tokenPath}`;
      });

      if (searchToken) {
        path += `&search=${encodeURIComponent(searchToken)}`;
      }

      window.location = path;
    }
  }

  global.FilteredSearchManager = FilteredSearchManager;
})(window.gl || (window.gl = {}));

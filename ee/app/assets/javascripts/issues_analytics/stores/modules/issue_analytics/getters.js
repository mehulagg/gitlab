export const hasFilters = (state) => Object.keys(state.filters).length > 0;
export const appliedFilters = (state) => state.filters;

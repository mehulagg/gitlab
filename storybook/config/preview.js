const stylesheetsRequireCtx = require.context(
  '../../app/assets/stylesheets',
  true,
  /application\.scss$/,
);

stylesheetsRequireCtx('./application.scss');

export const parameters = {
  actions: { argTypesRegex: '^on[A-Z].*' },
};

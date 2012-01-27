//
// Mustache style Underscore.js templating.
//---------------------------------------------------------------------------//
_.templateSettings = {
  evaluate: /\{\{(.+?)\}\}/g,
  interpolate: /\{\{\=(.+?)\}\}/g
};


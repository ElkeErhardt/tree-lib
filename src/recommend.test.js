const { recommend } = require('../');

test('valid recommendations', () => {
  expect(recommend('60E', 'de')).toStrictEqual(['Fichte']);
});

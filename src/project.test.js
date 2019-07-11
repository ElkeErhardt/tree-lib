const { project } = require('../');

test('valid projection', () => {
  expect(
    project({
      forestEcoregion: '1',
      additional: 'unknown',
      heightLevel: 'OSA',
      forestType: '59L',
      slope: 'unknown',
      tannenareal: 'unknown',
      relief: 'unknown',
      targetHeight: 'UM',
    }).forestType,
  ).toBe('1');
});

test('invalid location values', () => {
  expect(() =>
    project({ forestType: '60*', forestEcoregion: 'fooBar' }),
  ).toThrowError('fooBar for forestEcoregion is not valid.');

  // expect(() =>
  //   project({
  //     forestType: '59L',
  //     forestEcoregion: '1',
  //     targetHeight: 'OUM',
  //   }),
  // ).toThrowError('OUM is not valid targetHeight for this region.');

  expect(() =>
    project({ forestType: '60*', forestEcoregion: '1', heightLevel: 'fooBar' }),
  ).toThrowError('fooBar for heightLevel is not valid.');

  expect(() =>
    project({
      forestEcoregion: '1',
      heightLevel: 'HM',
      forestType: '55 collin',
    }),
  ).toThrowError('55 collin for forestType is not valid.');
});

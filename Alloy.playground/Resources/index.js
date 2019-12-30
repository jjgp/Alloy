function body() {
  Alloy.log('foobar');
  return Alloy.createElement(
    'VStack',
    { alignment: 'trailing', spacing: 10.0 },
    [
      Alloy.createElement('Text', { verbatim: 'Foobar' }, null),
      Alloy.createElement('Text', { verbatim: 'Barbaz' }, null),
      Alloy.createElement('Text', { verbatim: 'Quzquix' }, null),
      Alloy.createElement('Text', { verbatim: 'Barfoo' }, null),
    ]
  );
}

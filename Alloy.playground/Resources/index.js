function body() {
  Alloy.log('foobar');
  return Alloy.createElement(
    'VStack',
    { alignment: 'center', spacing: 50.0 },
    [
      Alloy.createElement('Text', { verbatim: 'alkfjela' }, null),
      Alloy.createElement('Text', { verbatim: 'afe' }, null),
      Alloy.createElement('Text', { verbatim: 'Quzquix' }, null),
      Alloy.createElement('Text', { verbatim: 'Barfoo' }, null),
    ]
  );
}

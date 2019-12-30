function body() {
  let element = Alloy.createElement('Text', { verbatim: 'Ann Arbor' }, null)
  Alloy.log(element);
  return Alloy.createElement(
    'VStack',
    { alignment: 'center', spacing: 10.0 },
    [
      element,
      Alloy.createElement('Text', { verbatim: 'Detroit' }, null),
      Alloy.createElement('Text', { verbatim: 'Lansing' }, null),
      Alloy.createElement('Text', { verbatim: 'Royal Oak' }, null),
    ]
  );
}

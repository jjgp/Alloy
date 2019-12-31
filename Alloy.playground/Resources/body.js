function body() {
  let element = Alloy.createElement('Text', { verbatim: 'Ann Arbor' }, null)
  Alloy.log(element);
  return Alloy.createElement(
    'VStack',
    { alignment: 'leading', spacing: 10.0 },
    [
      element,
      Alloy.createElement('Text', { verbatim: 'Detroit' }, null),
      Alloy.createElement(
        'VStack',
        { alignment: 'trailing' },
        [
          Alloy.createElement('Text', { verbatim: 'DIA' }, null),
          Alloy.createElement('Text', { verbatim: 'RenCen' }, null),
          Alloy.createElement('Text', { verbatim: 'StockX' }, null),
        ]
      ),
      Alloy.createElement('Text', { verbatim: 'Lansing' }, null),
      Alloy.createElement('Text', { verbatim: 'Royal Oak' }, null),
    ]
  );
}

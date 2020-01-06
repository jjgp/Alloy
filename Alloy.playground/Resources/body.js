function body() {
  let element = Alloy.createElement('Button', {
    action: () => {
      Alloy.log("Hello, world");
    }
  });
  Alloy.log(element);
  return Alloy.createElement(
    'VStack',
    {
      alignment: 'leading',
      spacing: 10.0,
      children: [
        element,
        (() => Alloy.createElement('Text', { verbatim: 'Evaluated Function!!!' }))(),
        Alloy.createElement('Text', { verbatim: 'Detroit' }),
        Alloy.createElement('Missing', { verbatim: 'Missing' }),
        Alloy.createElement(
          'HStack',
          {
            alignment: 'trailing',
            spacing: 5.0,
            children: [
              Alloy.createElement('Text', { verbatim: 'DIA' }),
              Alloy.createElement('Text', { verbatim: 'RenCen' }),
              Alloy.createElement('Text', { verbatim: 'StockX' }),
            ],
          },
        ),
        Alloy.createElement('Text', { verbatim: 'Lansing' }),
        Alloy.createElement('Text', { verbatim: 'Royal Oak' }),
      ],
    },
  );
}

#import('../../../../Applications/dart/dart-sdk/lib/unittest/unittest.dart');
#import('../bb.dart');

void main() {
  
  BBSeq col1 = new BBSeq('+1');
  BBSeq col2 = new BBSeq('+2');
  BBSeq col3 = new BBSeq('+3');
  BBSeq col4 = new BBSeq('+4');
  
  Set<BBSeq> bb10 = new Set<BBSeq>.from([new BBSeq('+A +B +C +A +1 +! +B +2 +! +C +3 +!'), new BBSeq('+A +B +2 +! +C +3 +!'), new BBSeq('+A +1 +! +B +2 +! +C +3 +!'), new BBSeq('+A +B +C +3 +!')]);
  Set<BBSeq> bb11 = new Set<BBSeq>.from([new BBSeq('+A +1 -2 -A'), new BBSeq('+A +2 -1 -A')]);
  
  test('dominating', () => expect(BBUtils.domColor(new BBSeq('A +1 -! -2 +3 +!')), new BBSeq('+1 +3')));
  
  test('normalize (1)', () => expect(BBUtils.normalize(new BBSeq('Z -5 X B C -1 +3')), new BBSeq('+A -1 +B +C +D -2 +3')));
  test('normalize (2)', () => expect(BBUtils.normalize(new BBSeq('+A -3 +2 -D +! -! -A -D +B -2 +3 -A')), new BBSeq('+A -1 +2 -B +! -! -A -B +C -2 +1 -A')));
  
  test('derivatives (1)', () => expect(BBUtils.derive(new BBSeq('+A +1 -2 -A')), new Set<BBSeq>.from([new BBSeq('+A +2 -1 -A')])));
  test('derivatives (2)', () => expect(BBUtils.derive(new BBSeq('+A +B +C +A +1 +! +B +2 +! +C +3 +!')), new Set<BBSeq>.from([new BBSeq('+A +B +2 +! +C +3 +!'), new BBSeq('+A +1 +! +B +2 +! +C +3 +!'), new BBSeq('+A +B +C +3 +!')])));
  
  test('allDerivates (1)', () => expect(BBUtils.deriveAll(new BBSeq('+A +B +C')), new Set<BBSeq>.from([new BBSeq('+A +B +C')])));
  test('allDerivates (2)', () => expect(BBUtils.deriveAll(new BBSeq('+A +B +C +A +1 +! +B +2 +! +C +3 +!')), bb10));
  test('allDerivates (3)', () => expect(BBUtils.deriveAll(new BBSeq('+A +1 -2 -A')), bb11));
  
  test('calcColors (1)', () {
    Map<BBSeq, num> res = BBUtils.calc(new BBSeq.BB11());
    
    expect(res[col1], 1/2);
    expect(res[col2], 1/2);
    
  });
  
  test('calcColors (2)', () {
    
    num epsilon = 0.0001;

    Map<BBSeq, num> res = BBUtils.calc(new BBSeq.BB10());
    expect(res[col1], closeTo(1/3, epsilon));
    expect(res[col2], closeTo(1/3, epsilon));
    expect(res[col3], closeTo(1/3, epsilon));
  });
  
  test('calcColors (3)', () {
    
    num epsilon = 0.0001;

    Map<BBSeq, num> res = BBUtils.calc(new BBSeq.BB12());
    expect(res[col1], closeTo(1 / 4, epsilon));
    expect(res[col2], closeTo(1 / 4, epsilon));
    expect(res[col3], closeTo(1 / 4, epsilon));
    expect(res[col4], closeTo(1 / 4, epsilon));
  });
}

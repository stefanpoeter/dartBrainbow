#import('../../../../Applications/dart/dart-sdk/lib/unittest/unittest.dart');
#import('../bb.dart');

void main() {
  
  group('Syntax test:', () {
    
    group('isLOX', () {
      test('+B', () => expect(BBSeq.isLox("+B")));    
      test(' c', () => expect(BBSeq.isLox("c")));
      test('-C', () => expect(BBSeq.isLox("-C")));
    
      test(' 1', () => expect(!BBSeq.isLox("1")));
      test('test', () => expect(!BBSeq.isLox("test")));
      test('a1', () => expect(!BBSeq.isLox("a1")));
      test(' 1', () => expect(!BBSeq.isLox("1")));
      test(' +', () => expect(!BBSeq.isLox("+")));
    });
    
    group('isCRE', () {      
      test('+1', () => expect(BBSeq.isCol("+1")));
      test(' 2', () => expect(BBSeq.isCol("2")));
      test('-3', () => expect(BBSeq.isCol("-3")));
      
      test(' a', () => expect(!BBSeq.isCol("a")));
      test('123', () => expect(!BBSeq.isCol("123")));
      test('test', () => expect(!BBSeq.isCol("test")));
      test('', () => expect(!BBSeq.isCol("")));
    });
    
    group('isTERM', () {
      test('+!', () => expect(BBSeq.isTerm("+!")));
      test('-!', () => expect(BBSeq.isTerm("-!")));
      test(' !', () => expect(BBSeq.isTerm("!")));
      test(' a', () => expect(!BBSeq.isTerm(" a")));
      test('-1', () => expect(!BBSeq.isTerm("-1")));
    });
    
    group('invert', () {
      test('-a', () => expect(new BBElement('-a').invert(), new BBElement('+a')));
      test('+!', () => expect(new BBElement('+!').invert(), new BBElement('-!')));
      test('1',  () => expect(new BBElement('1').invert(), new BBElement('-1')));
    });
    
    group('isElement', () {
      test('+A',    () => expect(BBSeq.isElement('+A')));
      test('+1',    () => expect(BBSeq.isElement('+1')));
      test('+!',    () => expect(BBSeq.isElement('+!')));
    });
    
    group('isSequence', () {
      test('empty', () => expect(BBSeq.isSequence('')));
      test('+A -1', () => expect(BBSeq.isSequence('+A -1')));
      test('+A -1 +2 -A', () => expect(BBSeq.isSequence('+A -1 +2 -A')));
      test('+A +B +1 -2 -B +B -3 +4 -A', () => expect(BBSeq.isSequence('+A +B +1 -2 -B +B -3 +4 -A')));
            
      test('not a sequence', () => expect(!BBSeq.isSequence('not a sequence')));
      
      test('equals', () => expect(new BBSeq('+A +1 -2 -A'), new BBSeq('A 1 -2 -A')));
      test('hashCode', () => expect(new BBSeq('+A +1 -2 -A').hashCode(), new BBSeq('A 1 -2 -A').hashCode()));

    });
    
  });
  
  group('Initialization', () {
    test('   +A   +1 -2   -A   ', () => expect(new BBSeq('   +A   +1 -2   -A   ').toString(), '+a +1 -2 -a'));
    test('A 1 -2 -A   ',          () => expect(new BBSeq('A 1 -2 -A').toString(), '+a +1 -2 -a'));
    test('   A   1    2  A   ',   () => expect(new BBSeq('A 1 2 A').toString(), '+a +1 +2 +a'));
  });
  
  group('Invert', () {
    test('from 0 to 3 : +A +1 -2 -A', () => expect(new BBSeq('+A +1 -2 -A').invert(0, 3), new BBSeq('+a +2 -1 -a')));
    test('from 1 to 2 : +A +1 -2 -A', () => expect(new BBSeq('+A +1 -2 -A').invert(1, 2), new BBSeq('+a +2 -1 -a')));
    test('from 0 to 3 : +A',          () => expect(() => new BBSeq('+A').invert(0, 3), throwsException));
    test('from 3 to 0 : +A +1 -2 -A', () => expect(() => new BBSeq('+A +1 -2 -A').invert(3, 0), throws));
  });
  
  group('Cut', () {
    test('from 0 length 3 : +A +1 -2 +A', () => expect(new BBSeq('+A +1 -2 +A').cut(0, 3), new BBSeq('+A')));
    test('from 0 length 2 : +A +1 +A -2', () => expect(new BBSeq('+A +1 +A -2').cut(0, 2), new BBSeq('+A -2')));
    test('from 5 length 3 : +A +1 +A',    () => expect(() => new BBSeq('+A +1 +A').cut(5, 3), throwsIllegalArgumentException));
  });
  
  group('Various', () {
    test('(+A +1) + (-2 -A) == (+A +1 -2 -A)', () => expect(new BBSeq('+A +1') + new BBSeq('-2 -A'), new BBSeq('+A +1 -2 -A')));
    test('(+A +1 -2 -A)[2] == (-2)', () => expect(new BBSeq('+A +1 -2 -A')[2], new BBElement('-2')));
  });
  
}

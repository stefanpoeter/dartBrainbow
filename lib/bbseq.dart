class BBElement implements Hashable{
  
  String _e;
  
  BBElement(this._e) {
    _e = _e.trim();
    _e = _e.toLowerCase();
    _checkSyntax();
    
      if (_e.length == 1) {
        _e = '+$_e'; 
      }
  }
  
  void _checkSyntax() {
    
    bool ok = BBSeq.isLox(_e) || BBSeq.isCol(_e) || BBSeq.isTerm(_e);
    
    if (!ok) {
      throw new IllegalArgumentException("Sequence element has a wrong syntax ($_e).");
    }
    
  }
  
  bool isPositive()     => _e.length == 1 || _e.substring(0, 1) == '+';
  bool isNegative()     => !isPositive();
  bool isLox()          => BBSeq.isLox(_e);
  bool isCol()          => BBSeq.isCol(_e);
  bool isTerm()         => BBSeq.isTerm(_e);
  
  String get symbol()   => _e.substring(1, 2);
  String get sign()     => _e.substring(0, 1);
  
  BBElement invert()    => new BBElement(isPositive() ? _e.replaceAll('+', '-') : _e.replaceAll('-', '+'));
  
  String toString()     => _e;
  
  operator ==(BBElement e)  => e.toString() == _e;
  
  int hashCode()            => isPositive() ? _e.charCodeAt(1) : _e.toUpperCase().charCodeAt(1);
  
}

typedef String BBModifier(int index, BBElement e);

/**
 * BBSeq is an immutable representation of a Brainbow Sequence.
 * 
 * Brainbow Sequences extends of lox, color and termination symbols and represent a
 * certain part of a genom system.
 * 
 * Lox-Symbols are Letters (A + Z), Colors are numbers (1 - 9) that are placed in one of two directions (+, -).
 * Terminal-Symbols are represented by a !.
 * 
 * Example: +A +1 +! -! -2 -A (Brainbow 1.1 Sequence)
 * 
 * Instantiate a new BBSeq by simply doing a new BBSeq('+A +1 +! -! -2 -A');
 * 
 **/
class BBSeq implements Iterable<BBElement>, Hashable {
  
  static final String _sgn   = '[+-]?';
  static final String _lox   = '[A-Za-z]';
  static final String _col   = '[1-9]';
  static final String _trm   = '!';
  static final String _slox  = '$_sgn$_lox';
  static final String _scol  = '$_sgn$_col';
  static final String _strm  = '$_sgn$_trm';
  static final String _elm   = '$_sgn($_lox|$_col|$_trm)';
  static final String _seq   = '(($_elm +)*$_elm)?';
  
  static RegExp _loxRegExp = const RegExp(@'^' '$_slox' @'$');
  static bool isLox(String s)         => _loxRegExp.hasMatch(s);
  
  static RegExp _colRegExp = const RegExp(@'^' '$_scol' @'$');
  static bool isCol(String s)         => _colRegExp.hasMatch(s);
  
  static RegExp _trmRegExp = const RegExp(@'^' '$_strm' @'$');
  static bool isTerm(String s)        => _trmRegExp.hasMatch(s);
  
  static RegExp _elmRegExp = const RegExp(@'^' '$_elm' @'$');
  static bool isElement(String s)     => _elmRegExp.hasMatch(s);
  
  static RegExp _seqRegEx = const RegExp(@'^' '$_seq' @'$');
  static bool isSequence(String s)    => _seqRegEx.hasMatch(s.trim());

  String _s;
  List<BBElement> _elements;
  
  BBSeq.Empty(): _elements = new List<BBElement>(), _s = '';
  BBSeq.BB10() {
    _s = '+A +B +C +A +1 +! +B +2 +! +C +3 +!';
    _init();
  }
  
  BBSeq.BB11() {
    _s = '+A +1 +! -! -2 -A';
    _init();
  }
  
  BBSeq.BB12() {
    _s = '+A +1 +! -! -2 -A +A +3 +! -! -4 -A';
    _init();
  }
  
  /**
   * Initiate a brainbow sequence simply by calling BBSeq('+A +1 -2 -A') or whatever sequence is relevant to you.
   * 
   **/ 
  BBSeq(this._s): _elements = new List<BBElement>() {
    _init();
  }
  
  void _init() {
    _elements = new List<BBElement>();
    
    if (_s == null) {
      _s == '';
    }
    
    _s = _s.trim();
    _s = _s.toLowerCase();
    
    if (_s == '') {
      return;
    }
    
    _checkSyntax();
    _removeDoubleSpaces();
    _populateElementList();
  }    
  
  void _populateElementList() {
    List<String> l = _s.split(' ');
    
    for (num i = 0; i < l.length; i += 1) {
      _elements.add(new BBElement(l[i]));
    }
    
  }
  
  void _removeDoubleSpaces() {
    
    bool changes = false;
    
    do {
      
      String newStr = _s.replaceAll("  ", " ");
      changes = newStr.length != _s.length;
      _s = newStr;
      
    } while(changes);
    
  }
  
  void _checkSyntax() {
    
      bool ok = isSequence(_s);
      
      if (!ok) {
        throw new IllegalArgumentException('Illegal Brainbow syntax ($_s).');
      }
    
  }
  
  /**
   * Create a modified sequence by passing range values {from} and {to} and a modifier 
   * function (int index, BBModifier fnc);
   * 
   * 
   **/
  BBSeq modify(int first, int last, BBModifier mod) {
    
    if (Math.min(first, last) < 0 || Math.max(first, last) >= _elements.length) {
      throw new IllegalArgumentException('{first}($first) and {last}($last) are invalid for this sequence.');
    }
    
    String s = '';
    int i = first;
    int dir = (first < last) ? +1 : -1;
    
    do {
      String tmp = mod(i, _elements[i]);
      if (tmp != null) { 
        s = '$s $tmp'; 
      }
      
      if (dir > 0 && i >= last) {
        break;
      }
      
      if (dir < 0 && i <= last) {
        break;
      }
      
      i += dir;
      
    } while (true);
    
    return new BBSeq(s);
  }
  
  /**
   * Invert the element from index {from} till index {to}
   * Example new BBSeq('+A +1 -2 -A').invert() == new BBSeq('+A +2 -1 -A')
   **/
  BBSeq invert(int from, int to) {
    if (from >= to) {
      throw new IllegalArgumentException('{from} cannot be greater or equal than {to}');
    }
    
    BBSeq pre = new BBSeq('');
    
    if (from != 0) {
      pre = modify(0, from - 1, (i, e) => e.toString());
    }
    BBSeq inn = modify(to, from, (i, e) => e.invert().toString());
    BBSeq pst = new BBSeq('');
    
    if (to != _elements.length - 1) {
      pst = modify(to + 1, _elements.length - 1, (i, e) => e.toString());
    }
    
    return pre + inn + pst;
  }
  
  /**
   * Cut from index {from} till {length} is reached.
   * Example: new BBSeq('+A +1 +2 +A').cut(0, 3) == new BBSeq('+A')
   **/
  BBSeq cut(int from, int length) {
    if (length < 0 || from < 0 || from + length >= _elements.length) {
      throw new IllegalArgumentException('{from}($from) or {length}($length) are not valid.');
    }
    
    BBSeq mod = modify(0, _elements.length - 1, (i, e) {
      if (i < from || i >= from + length) {
        return _elements[i].toString();
      } 
    });
    
    return mod;
  }
  
  String toString() {
    String s = '';
    for (num i = 0; i < _elements.length; i += 1) {
      String e = _elements[i].toString();
      s = '$s $e';
    }
    
    return s.trim();
  }
  
  int hashCode() {
    int hc = 0;
    for (int i = 0; i < _elements.length; i += 1) {
      BBElement bbe = _elements[i];
      int v = bbe.hashCode();
      hc += (i+1) * v;
    }
    
    return hc;
  }
  
  bool operator ==(BBSeq s)       => s != null && hashCode() == s.hashCode();
  BBElement operator [](int i)    => _elements[i];
  BBSeq operator +(Object seq)    => _concat(seq);
  
  BBSeq _concat(Object o) {
    if (o is BBSeq || o is BBElement) {
      return new BBSeq('$_s $o');
    }
  }
  
  Iterator<BBElement> iterator()  => _elements.iterator();
  int get length()  => _elements.length;
  

}

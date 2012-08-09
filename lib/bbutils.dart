
class BBUtils {
  
  /**
   * 
   * Extract the dominating color in {seq}.
   * Example: domColor('+A -! -2 +1 +!') == new BBSeq('+1');
   * 
   **/
  static BBSeq domColor(BBSeq seq) {
    
    BBSeq s = new BBSeq.Empty();
    
    for (BBElement e in seq) {
      
      if (e.isCol() && e.isPositive()) {
        s += e;
      }
      
      if (e.isTerm() && e.isPositive()) {
        break;
      }
      
    }
    
    return s;
  }
  
  /**
   * 
   * Normalize {seq}.
   * Example: normalize('+Z +9 -8 -Y -C +3 -2') == new BBSeq('+A +1 -2 -B -C +3 -4')
   * 
   */ 
  static BBSeq normalize(BBSeq seq) {
    
    int alphabetIndex = 'a'.charCodeAt(0);
    int numberIndex = '1'.charCodeAt(0);
    Map<String, String> charmap = new Map<String, String>();

    BBSeq norm = seq.modify(0, seq.length-1, (i, e) {

      // terminal symbols did not need to be changed
      if (e.isTerm()) {
        return e.toString();
      }
        
      // check for containing symbols
      if (charmap.containsKey(e.symbol)) {
        String s = charmap[e.symbol];
          
        if (e.isPositive()) s = '+$s'; else  s = '-$s';
        
        return s;
      } 
      
      
      // create a new sign
      List<num> codes = (e.isLox() ? [alphabetIndex] : [numberIndex]);
      charmap[e.symbol] = new String.fromCharCodes(codes);
      String s = charmap[e.symbol];
      
      if (e.isPositive()) s = '+$s'; else s = '-$s';
      
      if (e.isLox()) {
        alphabetIndex += 1;
      } else {
        numberIndex += 1;
      }
      
      return s;
        
    });
    
    return norm;
    
  }
  
  /**
   *
   * Derive all direct permutations from {seq}.
   * Example: derive('+A +B +A +1 +! +B +2 +!') == { '+A +1 +! +B +2 +!', '+A +B +2 +!' }
   * 
   */
  static Set<BBSeq> derive(BBSeq seq) {
    
    Set<BBSeq> result = new Set<BBSeq>();
    
    for (int i = 0; i < seq.length - 1; i += 1) {

      BBElement f = seq[i];
      
      if (!f.isLox()) {
        continue;
      }

      for (int j = i + 1; j < seq.length; j += 1) {

        BBElement s = seq[j];
        
        if (!s.isLox() || f.symbol != s.symbol) {
          continue;
        }
         
        if (f.sign == s.sign) {
          result.add(seq.cut(i, j-i));
        }
          
        if (f.sign != s.sign) {
          result.add(seq.invert(i, j));
        }
      } 
    }
    
    return result;    
  }
  
  /**
   *
   * Calculates all permutations that {seq} can become.
   * Example: derviveAll('+A +1 -2 -A') == { '+A +1 -2 -A', '+A +2 -1 -A' } 
   * 
   */
  static Set<BBSeq> deriveAll(BBSeq seq) {
    Set<BBSeq> marked = new Set<BBSeq>();
    Queue<BBSeq> q = new Queue<BBSeq>();
    q.addLast(seq);
        
    while (!q.isEmpty()) {
      BBSeq cur = q.removeLast();
      marked.add(cur);
            
      Set<BBSeq> next = BBUtils.derive(cur);
      
      for (BBSeq bs in next) {
        if (marked.contains(bs)) {
          continue;
        }
        
        q.addLast(bs);
      }
      
    }
    
    return marked;
  }
  
  static Matrix _adjMatrix(List<BBSeq> allSeqs) {
    
    Matrix matrix = new Matrix(allSeqs.length, allSeqs.length);
    
    // populate initial matrix
    for (num i = 0; i < allSeqs.length; i += 1) {
      BBSeq cur = allSeqs[i];
      
      Set<BBSeq> derv = derive(cur);
      
      // adding self loop
      int length = derv.length + 1;
      matrix[new Pos(i, i)] = 1 / length;
      for (BBSeq trg in derv) {
        Pos p = new Pos(allSeqs.indexOf(trg), i);
        matrix[p] += 1 / length;
      }
      
    }
    
    return matrix;

  }
  
  static Vector _startVector(List<BBSeq> allSeqs, BBSeq src) {
    Vector s = new Vector(allSeqs.length);
    s[allSeqs.indexOf(src)] = 1;
    
    return s;
  }
  
  static Matrix _calcLimes(Matrix adj, num epsilon) {
    Matrix m;
    Matrix odd = new Matrix.from(adj);
    Matrix even = odd * adj;
    Matrix lastSum = (odd + even) / 2;
    // run the calculations
    for (int i = 0; i < 100; i += 1) {
      
      odd = odd * adj;
      even = odd * adj;
      
      m = (odd + even) / 2;
      
      num bigDiff = 0;
      m.make((row, col, v) => bigDiff = Math.max(bigDiff, v - lastSum[new Pos(row, col)]));
      
      if (bigDiff < epsilon) {
        break;
      }
      
      lastSum = new Matrix.from(m);
            
    }
    
    return m;

  }
  
  static Map<BBSeq, num> _createColMap(List<BBSeq> allSeqs, Vector result) {
    Map<BBSeq, num> colMap = new Map<BBSeq, num>();
    for (int i = 0; i < result.rows; i += 1) {
      BBSeq cur = allSeqs[i];
      BBSeq col = domColor(cur);
      num p = result[i];
      
      if (!colMap.containsKey(col)) {
        colMap[col] = 0; 
      }
      
      num op = colMap[col];
      colMap[col] += p;
    }
    
    return colMap;
  }
  
  /**
   *
   * Calculates the color mapping from {seq}, optionally add an {epsilon}.
   * Example: calc('+A +1 -2 -A') = { '+1': 0.5, '+2': 0.5 }
   * 
   **/
  static Map<BBSeq, num> calc(BBSeq seq, [num epsilon = 0.00001]) {
    List<BBSeq> allSeqs = new List.from(deriveAll(seq));
    
    Matrix matrix = _adjMatrix(allSeqs);
    Vector start = _startVector(allSeqs, seq);
    Matrix limes = _calcLimes(matrix, epsilon);
    
    Vector res = start * limes;    
    Map<BBSeq, num> colMap = _createColMap(allSeqs, res);
    
    return colMap;
    
  }
  
}

#library('bbmatrix');

#import('../../../Applications/dart/dart-sdk/lib/unittest/unittest.dart');

class Pos {
  int row, col;
  Pos(this.row, this.col);
}

typedef num MatrixMod(int row, int col, num value);

class Matrix {
  
  List<List<num>> _m;
  
  int _rows, _cols;
  
  Matrix(this._rows, this._cols) {
    _initEmpty();
  }
  
  Matrix.from(Matrix m) {
    this._rows = m.rows;
    this._cols = m.cols;
    _initEmpty();
    
    for (int i = 0; i < _rows; i += 1) {
      for (int j = 0; j < _cols; j += 1) {
        _m[i][j] = m[new Pos(i, j)];
      }
    }
  }
  
  void _initEmpty() {
    _m = (new List<List<num>>());
    for (int i = 0; i < _rows; i += 1) {
      _m.add(new List<num>());
      for (int j = 0; j < _cols; j += 1) {
        _m[i].add(0);
      }
    }
  }
  
  Matrix make(MatrixMod mod) {
    Matrix r = new Matrix(_rows, _cols);
    for (int i = 0; i<_rows; i += 1) {
      for (int j = 0; j < _rows; j += 1) {
        r[new Pos(i, j)] = mod(i, j, _m[i][j]);
      }
    }
    return r;
  }
  
  operator [](Pos pos)                     => _m[pos.row][pos.col];
  operator []=(Pos pos, num value)         => _m[pos.row][pos.col] = value; 
  Matrix operator +(Matrix m)              => make((row, col, val) => m[new Pos(row, col)] + val);
  Matrix operator -(Matrix m)              => make((row, col, val) => - val - m[new Pos(row, col)]);
  Matrix operator /(num v)                 => make((row, col, val) => _m[row][col] / v);
  Matrix operator *(Matrix m) {
    
    if (_rows != m.cols) {
      throw new IllegalArgumentException();
    }
    
    return make((row, col, val) {
      num v = 0;
      for (int i = 0; i < rows; i += 1) {
        v += _m[row][i] * m[new Pos(i, col)];
      }
      
      return v;
    
    });
    
  }
  
  int get rows()    => _rows;
  int get cols()    => _cols;
  
  String toString() => _m.toString();
  
}

class Vector {
  
  List<num> _v;
  int _rows;
  
  Vector(this._rows): _v = new List<num>() {
    for (int i = 0; i < _rows; i += 1) {
      _v.add(0);
    }
  }
  
  num operator [](int row)              => _v[row];
  operator []=(int row, num value)      => _v[row] = value;
  Vector operator *(Matrix m) {
    if (_rows != m.cols) {
      throw new IllegalArgumentException();
    }
    
    Vector v = new Vector(_rows);
    
    m.make((row, col, val) => v[row] += _v[col] * val);
    
    return v;
  }
  
  num get rows()            => _rows;
  
}

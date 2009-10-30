require 'matrix'

Infinity = 1.0 / 0.0

class Matrix
  def []=(i,j,x)
    @rows[i][j] = x
  end
  
  def Matrix.infinity m, n
    Matrix.rows(Array.new(m){Array.new(n, Infinity)})
  end
end

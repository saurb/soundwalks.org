require 'matrix'

Infinity = 1.0 / 0.0

# Why Matrix isn't built with this is beyond me.
class Matrix
  def []=(i,j,x)
    @rows[i][j] = x
  end
end

# Normalize a log-likelihood similarity matrix to be a scaled distance matrix.
def normalize_affinity(matrix)
  ones = Matrix.row_vector(Array.new(matrix.row_size) {1})
  diag = Matrix.column_vector(Array.new(matrix.row_size) {|i| matrix[i, i]})
  
  (diag * ones) + (ones.transpose * diag.transpose) - matrix - matrix.transpose
end

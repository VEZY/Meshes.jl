# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    UniformPartition(k, [shuffle])

A method for partitioning spatial objects uniformly into `k` subsets
of approximately equal size. Optionally `shuffle` the data (default
to `true`).
"""
struct UniformPartition <: PartitionMethod
  k::Int
  shuffle::Bool
end

UniformPartition(k::Int) = UniformPartition(k, true)

function partition(object, method::UniformPartition)
  n = nelements(object)
  k = method.k

  @assert k ≤ n "number of subsets must be smaller than number of points"

  inds = method.shuffle ? shuffle(1:n) : collect(1:n)
  subsets = collect(Iterators.partition(inds, n ÷ k))

  Partition(object, subsets)
end

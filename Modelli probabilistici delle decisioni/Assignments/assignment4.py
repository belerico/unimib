import math
import numpy
from numpy import linalg

def allclose(A: numpy.matrix, B: numpy.matrix, **kwargs):
    """
    Since `numpy.allclose` method doesn't work as expected
    """
    return numpy.all(list(map(
        lambda a,b: math.isclose(a, b, **kwargs), A.A1, B.A1 
    )))

def stationary_dist(P: numpy.matrix, type: str, **kwargs):
    """
    Given a transition probabilities matrix P, this function computes
    the stationary distribution pi. One can choose two different methods:
    - naive: power method; loop until P^k == P^(k+1), within a certain tolerance
    (look at the method `numpy.allclose`)
    - linear: solve a linear system pi' = (pi * P)', where pi is a row vector of
    indipendent variables
    It returns the array of stationary distribution and the power k+1 such that
    P^k = P^(k+1), None if type is linear

    **kwargs is the keyword argument accepted by `math.isclose` function
    """
    # Check that P is a square matrix
    # assert(reduce(operator.and_, [len(row) == len(P) for row in P]) == True)
    assert(P.shape[0] == P.shape[1])
    if type == 'naive':
        P_k = P
        P_k_1 = P ** 2
        power = 2
        while (not allclose(P_k, P_k_1, **kwargs)):
            P_k = P_k_1
            P_k_1 = P_k * P
            power += 1
        return numpy.array(P_k_1[0].flat), power
    elif type == 'linear':
        """
        The linear system that one might resolve is, 
        with pi a row vector of indipendent variables:
        (pi * P)' = pi'
        P' * pi' - pi' = 0
        Since pi is the vector of indipendent variables, the operation (- pi')
        is the same as subtract 1 from every element in the diagonal of P' * pi'.
        In order to obtain a unique solution we must replace one of the equation
        with sum(pi_i) = 1 for all i from 0 to n-1. In this case I choose the first one
        """
        P = P.T
        P[numpy.diag_indices_from(P)] -= 1
        P[0,:] = numpy.ones(P.shape[0])
        b = numpy.zeros(P.shape[0])
        b[0] = 1
        return linalg.solve(P, b), None
    else:
        raise Exception('Type unspecified')

# 1) Matrice delle probabilità di transizione
P = numpy.matrix([
    [.5, .5, 0, 0, 0],
    [.5, 0, .5, 0, 0],
    [.5, 0, 0, .5, 0],
    [.5, 0, 0, 0, .5],
    [.5, 0, 0, 0, .5]]
)
print('Matrice delle probabilità di transizione\n', P)

# 2) Matrice delle probabilità di transizione a due step
P_2 = P ** 2
print('Matrice delle probabilità di transizione a due step\n', P_2)

# 3) Calcolare la distribuzione stazionaria
print('Distribuzione stazionaria\n', stationary_dist(P, 'naive'))


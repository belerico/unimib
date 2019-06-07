import math
import numpy
from numpy import linalg

class HMM(object):

    def __init__(self, 
        pi: numpy.ndarray, 
        T: numpy.matrix, 
        O: numpy.matrix,
        states=None,
        emissions=None):

        """
        pi: initial probability distribution
        T : transition probability matrix
        O : emission probability matrix
        states: list of state names
        emissions: list of emission names
        """

        self.pi = pi
        assert(len(pi) == T.shape[0])
        assert(sum(pi) == 1)

        self.T = T
        assert(T.shape[0] == T.shape[1])
        assert(int(sum(T.A1)) == T.shape[0])

        self.O = O
        assert(O.shape[0] == T.shape[0])
        assert(int(sum(O.A1)) == O.shape[0])

        self.states = states
        if self.states:
            assert(len(self.states) == T.shape[0])
        
        self.emissions = emissions
        if self.emissions:
            assert(len(emissions) == O.shape[1])
    
    def allclose(self, A: numpy.matrix, B: numpy.matrix, **kwargs):
        """
        Since `numpy.allclose` method doesn't work as expected
        """
        return numpy.all(list(map(
            lambda a,b: math.isclose(a, b, **kwargs), A.A1, B.A1 
        )))

    def stationary_dist(self, type: str, **kwargs):
        """
        Given a transition probabilities matrix T, this function computes
        the stationary distribution pi. One can choose two different methods:
        - naive: power method; loop until T^k == T^(k+1), within a certain tolerance
        (look at the method `numpy.allclose`)
        - linear: solve a linear system pi' = (pi * T)', where pi is a row vector of
        indipendent variables
        It returns the array of stationary distribution and the power k+1 such that
        T^k = T^(k+1), None if type is linear

        **kwargs is the keyword argument accepted by `math.isclose` function
        """
        # Check that T is a square matrix
        # assert(reduce(operator.and_, [len(row) == len(T) for row in T]) == True)
        assert(self.T.shape[0] == self.T.shape[1])
        if type == 'naive':
            T_k = self.T
            T_k_1 = self.T ** 2
            power = 2
            while (not self.allclose(T_k, T_k_1, **kwargs)):
                T_k = T_k_1
                T_k_1 = T_k * self.T
                power += 1
            return numpy.array(T_k_1[0].flat), power
        elif type == 'linear':
            """
            The linear system that one might resolve is, 
            with pi a row vector of indipendent variables:
            (pi * T)' = pi'
            T' * pi' - pi' = 0
            Since pi is the vector of indipendent variables, the operation (- pi')
            is the same as subtract 1 from every element in the diagonal of T' * pi'.
            In order to obtain a unique solution we must replace one of the equation
            with sum(pi_i) = 1 for all i from 0 to n-1. In this case I choose the first one
            """
            self.T = self.T.T
            self.T[numpy.diag_indices_from(self.T)] -= 1
            self.T[0,:] = numpy.ones(self.T.shape[0])
            b = numpy.zeros(self.T.shape[0])
            b[0] = 1
            return linalg.solve(self.T, b), None
        else:
            raise Exception('Type unspecified')

    def forward(self, observations):
        f = self.pi
        message_f = [f]
        for obs in observations:
            f = (f @ self.T @ numpy.diag(self.O[:, obs].T.A1)).A1
            message_f.append(f / sum(f))
        return message_f

    def backward(self, observations):
        b = [1, 1]
        message_b = [b]
        for i in range(len(observations)-1, -1, -1):
            b = (self.T @ numpy.diag(self.O[:, observations[i]].T.A1) @ b).A1
            message_b.append(b / sum(b))
        return message_b

    def smoothing(self, observations):
        def normalized_hadamard(v1, v2):
            res = numpy.multiply(v1, v2)
            return res / sum(res)

        return list(
            map(normalized_hadamard, 
                self.forward(observations), 
                list(reversed(self.backward(observations)))
            )
        )

    def viterbi(self, observations: list):
        """
        Viterbi algorithm in matrix form
        """
        # Compute initial probability given the first observation
        S = numpy.matrix(numpy.diag(self.pi) @ numpy.diag(self.O[:, observations[0]].T.A1))
        saved_max = []
        for obs in observations[1:]:
            # Get, for every cols, the row of the max value
            amax = numpy.argmax(S, axis=0).A1
            max_per_col = []
            # Get max values per columns
            for col in range(len(self.T)):
                max_per_col.append(S[amax[col], col])
            # 'Forward' pass
            S = numpy.diag(max_per_col) @ self.T @ numpy.diag(self.O[:, obs].T.A1)
            # Save where the maximum comes from (needed fro the 'backward' pass)
            saved_max.append(amax)
        # Get indices of the global max
        row, col = numpy.unravel_index(numpy.argmax(S, axis=None), S.shape)
        # Cols will be the state, row becomes col while running backward
        sequence = [self.states[col] if self.states else col]
        for i in range(len(saved_max)-1, -1, -1):
            sequence.append(self.states[row] if self.states else row)
            row = saved_max[i][row]
        return list(reversed(sequence))

if __name__ == "__main__":
    pi = numpy.array([0.52, 0.48])
    T = numpy.matrix([[0.6, 0.4], [0.17, 0.83]])
    O = numpy.matrix([[1/10, 1/10, 1/10, 1/10, 1/10, 1/2], [1/6]*6])
    
    # pi = numpy.array([0.98, 0.02])
    # T = numpy.matrix([[0.4, 0.6], [0.1, 0.9]])
    # O = numpy.matrix([[0.8, 0.2], [0.1, 0.9]])
    
    # pi = numpy.array([.5, .5])
    # T = numpy.matrix([[.7, .3], [.3, .7]])
    # O = numpy.matrix([[.9, .1], [.2, .8]])

    hmm = HMM(pi, T, O, ['Loaded', 'Fair'])
    
    print(hmm.viterbi([2,0,5,5,5,3]))
    # print(hmm.viterbi([1, 0, 1]))
    # print(hmm.forward([0, 0, 1, 0]))
    # print(list(reversed(hmm.backward([0, 0, 1, 0]))))
    print(hmm.smoothing([0, 0, 1, 0]))
        


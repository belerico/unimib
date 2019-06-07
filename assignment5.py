import numpy

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
        assert(sum(pi) == 1)

        self.T = T
        assert(T.shape[0] == T.shape[1])
        assert(int(sum(T.A1)) == T.shape[0])

        self.O = O
        assert(O.shape[0] == T.shape[0])
        assert(int(sum(O.A1)) == O.shape[0])

        self.states = states
        self.emissions = emissions
    
    def viterbi(self, observations: list):
        """
        Viterbi algorithm in matrix form
        """
        # Compute initial probability givern the first observation
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
        # Cols will be the state, row becomes col running backward
        sequence = [self.states[col] if self.states else col]
        for i in range(len(saved_max)-1, -1, -1):
            sequence.append(self.states[row] if self.states else row)
            row = saved_max[i][row]
        return list(reversed(sequence))

if __name__ == "__main__":
    # pi = numpy.array([0.52, 0.48])
    # T = numpy.matrix([[0.6, 0.4], [0.17, 0.83]])
    # O = numpy.matrix([[1/10, 1/10, 1/10, 1/10, 1/10, 1/2], [1/6]*6])
    pi = numpy.array([0.98, 0.02])
    T = numpy.matrix([[0.4, 0.6], [0.1, 0.9]])
    O = numpy.matrix([[0.8, 0.2], [0.1, 0.9]])
    hmm = HMM(pi, T, O, ['climb', 'not climb'])
    print(hmm.viterbi([1, 0, 1]))
    # print(hmm.viterbi([2,0,5,5,5,3]))
        


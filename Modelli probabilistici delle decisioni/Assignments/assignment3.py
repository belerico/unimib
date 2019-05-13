import numpy
import random
import operator
from functools import reduce
from operator import itemgetter
from itertools import accumulate
from collections.abc import Iterable

class assignment3():

    def __init__(
        self,
        variables: list,
        adj: numpy.ndarray,  
        cpts: list
    ):
        """
        variables: list of variables names in topological order
        adj: adj matrix as numpy array. adj[i, j] = 1 iff exists a directed edge from node j to node i. 
             Nodes in rows and cols must follow the topological order specified by variables. So, if variables
             contains ['A', 'B', 'C'], then adj will be
             A B C 
             ------
             0 0 0 | A
             1 0 0 | B
             1 1 0 | C
        cpts: list of cpts for every variable following the topological order of vars.
              Cpts are arrays containing only the true values, which are stored based on the combinatorial order, 
              for example, for the Bayesian net in this assignment:
              if the topological order is [H, W, A, J] then the cpt for J is
              H, W, A | P(J|H,W,A)
              0  0  0 | 0.1
              0  0  1 | 0.6
              0  1  0 | 0.3
              0  1  1 | 0.5
              1  0  0 | 0.95
              1  0  1 | 0.95
              1  1  0 | 0.95
              1  1  1 | 0.95
              then cpts[3] = [0.1, 0.6, 0.3, 0.5, 0.95, 0.95, 0.95, 0.95]
        evidence: dict of variable:value
        """
        # Check that adj is a square matrix
        assert(reduce(operator.and_, [len(row) == len(adj) for row in adj]) == True)
        assert(len(adj) == len(variables) == len(cpts))
        self.adj = adj
        self.variables = variables
        self.cpts = cpts

    def discrete_sampling(self, n: int, pdf: Iterable, values: Iterable):
        assert(n > 0)
        assert(sum(pdf) == 1)
        assert(len(pdf) == len(values))
        return self.__discrete_sampling(n, pdf, values)  
    
    def __discrete_sampling(self, n: int, pdf: Iterable, values: Iterable):
        # Pair up probabilities and values
        pdf_values = list(zip(pdf, values))
        # Sort them 
        pdf_values.sort(reverse=True)
        # Compute the cumulative sum over pdfs
        # cdf_values = list(zip(list(accumulate([x[0] for x in pdf_values])), [x[1] for x in pdf_values]))
        cdf_values = [pdf_values[0]] + [(pdf_values[i][0] + pdf_values[i-1][0], pdf_values[i][1]) for i in range(1, len(pdf_values))]
        # sorted_indices = numpy.argsort(pdf)
        # cdf = numpy.cumsum([pdf[i] for i in reversed(sorted_indices)])
        # cdf_values = list(zip(cdf, [values[i] for i in reversed(sorted_indices)]))
        sample = numpy.zeros(n)
        for i in range(0, n):
            for p, value in cdf_values:
                rand = random.random()
                if (rand <= p):
                    sample[i] = value
                    break
        return sample 
    
    def likelihood_weighting(self, n:int, target:str, evidences: dict):
        # Supposing we're working with boolean variables, then the possible outcome are two: true or false
        # First value is the probability of target being false, the second is the probability of target being true
        W = numpy.zeros(2)
        # Index of the target variables in the topoligical order
        target_index = self.variables.index(target)
        # Algorithm from Norvig book
        for _ in range(0, n):
            x, w = self.weighted_sampling(evidences)
            target_value = x[target_index]
            W[target_value] = W[target_value] + w
        # Normalizing factor
        alpha = 1 / numpy.sum(W)
        return W * alpha

    def weighted_sampling(self, evidences: dict):
        """
        evidence: dict of variable:value
        """
        # Algorithm from Norvig book
        w = 1
        # Array storing the variables values sampled so far, always following the topological order
        x = numpy.empty(len(self.variables), dtype='u1')
        for i, var in enumerate(self.variables):
            parents = numpy.where(self.adj[i] == 1)[0]
            try:
                # If an exception is raised, then it's not an evidence vars
                x[i] = evidences[var]
                row_cpt = 0
                if parents.size > 0:
                    # Get the parents values in topological order
                    parents_values = x[parents]
                    # Get index of the cpt row
                    # To do that, knowing that cpts are stored as previously specified
                    # i concatenate the boolean values of the evidences computed so far to obtain a 2-mod number
                    # and then convert it to its decimal representation, obtaining the requested row
                    row_cpt = int(''.join(str(i) for i in parents_values), 2)
                # Update the weight
                w = w * (self.cpts[i][row_cpt] if x[i] == 1 else 1 - self.cpts[i][row_cpt])
            except KeyError:
                row_cpt = 0
                if parents.size > 0:
                    # Get the parents values in topological order
                    parents_values = x[parents]
                    # Get index of the cpt row
                    row_cpt = int(''.join(str(i) for i in parents_values), 2)
                # Update the evidences
                x[i] = self.__discrete_sampling(1, [self.cpts[i][row_cpt], 1 - self.cpts[i][row_cpt]], [1, 0])[0]
        return x, w

if __name__ == "__main__":
    adj = numpy.array([
       # B M I G J
        [0,0,0,0,0], # B
        [0,0,0,0,0], # M
        [1,1,0,0,0], # I
        [1,1,1,0,0], # G
        [0,0,0,1,0]  # J
    ])
    # Variables in topological order
    variables = ['B', 'M', 'I', 'G', 'J']
    cpts = [
        [0.9], # P(B)
        [0.1], # P(M)
        [0.1, 0.5, 0.5, 0.9], # P(I|B,M)
        [0, 0, 0.1, 0.2, 0, 0, 0.8, 0.9], # P(G|B,M,I)
        [0, 0.9] # P(J|G)
    ]
    evidences = {'B':1, 'M':1, 'I':1}
    ass3 = assignment3(variables, adj, cpts)
    print(ass3.likelihood_weighting(50000, 'J', evidences))
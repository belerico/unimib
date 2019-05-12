import numpy
import random
from operator import itemgetter
from itertools import accumulate
from collections.abc import Iterable

class assignment3():

    def __init__(
        self,
        adj: numpy.ndarray, 
        variables: list, 
        cpts: list, 
        seed=42, 
        *args, 
        **kwargs
    ):
        """
        adj: adj matrix as numpy array. adj[i, j] = 1 iff exists a directed edge from node j to node i
        vars: list of variables names in topological order
        cpts: list of cpts for every variable following the topological order of vars\n
              Cpts are stored as array with only the true value, the topological order and combinatorial order, for example:
              if the topoligical order is [H, W, A, J] and the cpt is
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
        self.adj = adj
        self.variables = variables
        self.cpts = cpts

    def discrete_sampling(self, n: int, pdf: Iterable, values: Iterable):
        assert(n > 0)
        assert(sum(pdf) == 1)
        assert(len(pdf) == len(values))
        # Pair up probabilities and values
        pdf_values = list(zip(pdf, values))
        # Sort them 
        pdf_values.sort(reverse=True)
        # Compute the cumulative sum over pdfs
        cumulative = list(zip(list(accumulate([x[0] for x in pdf_values])), [x[1] for x in pdf_values]))
        sample = [None] * n
        for i in range(0, n):
            for p, value in cumulative:
                rand = random.random()
                if (rand <= p):
                    sample[i] = value
                    break
        return sample   
    
    def likelihood_weighting(self, n:int, target:str, evidences: dict):
        # Supposing we're working with boolean variables, then the possible outcome are two: true or false
        W = numpy.zeros(2)
        # Algorithm from Norvig book
        for _ in range(0, n):
            x, w = self.weighted_sampling(evidences)
            target_value = x[self.variables.index(target)]
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
        x = numpy.empty(len(self.variables), dtype='u1')
        for i, var in enumerate(self.variables):
            parents = numpy.where(self.adj[i] == 1)[0]
            try:
                # If an exception is raised, then it's not an evidence vars
                x[i] = evidences[var]
                row_cpt = 0
                if parents.size > 0:
                    # Get the parents in topological order
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
                    # Get the parents in topological order
                    parents_values = x[parents]
                    # Get index of the cpt row
                    row_cpt = int(''.join(str(i) for i in parents_values), 2)
                # Update the evidences
                x[i] = self.discrete_sampling(1, [self.cpts[i][row_cpt], 1 - self.cpts[i][row_cpt]], [1, 0])[0]
        return x, w

if __name__ == "__main__":
    adj = numpy.array([
       # H W A J
        [0,0,0,0], # H
        [0,0,0,0], # W
        [0,1,0,0], # A
        [1,1,1,0]  # J
    ])
    variables = ['H', 'W', 'A', 'J']
    cpts = [
        [0.2], # P(H)
        [0.5], # P(W)
        [0.3, 0.1], # P(A|W)
        [0.1, 0.6, 0.3, 0.5, 0.95, 0.95, 0.95, 0.95] # P(J|H,W,A)
    ]
    evidences = {'A':1}
    ass3 = assignment3(adj, variables, cpts)
    print(ass3.likelihood_weighting(50000, 'J', evidences))
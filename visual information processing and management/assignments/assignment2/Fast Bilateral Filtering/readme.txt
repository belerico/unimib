This is the MATLAB implementation of the fast bilateral filter described 
in the following papers:

[1] K.N. Chaudhury, D. Sage, and M. Unser, "Fast O(1) bilateral filtering using trigonometric range kernels," IEEE Trans. Image 
Processing, vol. 20, no. 11, 2011.

[2] K.N. Chaudhury, "Acceleration of the shiftable O(1) algorithm for
bilateral filtering and non-local means,"  IEEE Transactions on Image Proc., 
vol. 22, no. 4, 2013.

[3] S. Ghosh and K.N. Chaudhury, "On fast bilateral filtering using 
Fourier kernels," IEEE Signal Processing Letters, vol. 23, no. 5, 
pp. 570-573, 2016.

Authors :  Kunal N. Chaudhury, Sanjay Ghosh, Anmol Popli.
Date      :  April 6, 2016.

To run the software use:
===============
[ fout , param ]  =  shiftableBF(fin, sigmas, sigmar, tol);

INPUT
=====
fin              :  input grayscale image
fout           : bilateral filter output
sigmas       : width of spatial Gaussian
sigmar       : width of range Gaussian

OUTPUT
======
fout     : filtered image
param  : list of parameters


 

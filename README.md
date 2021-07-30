# SIMPAC_decoding
Repository for SIMPAC speed and acceleration decoding manuscript

This code has been used in:

Wirtshafter, H. S. and M. A. Wilson (2019). "Locomotor and Hippocampal Processing Converge in the Lateral Septum." Curr Biol 29(19): 3177-3192. https://www.sciencedirect.com/science/article/pii/S0960982219310152

This repository provides the code needed to do Bayesian decoding of velocity and acceleration, as well as sample data.

------------------------------------------------------------

Code was written and run in Matlab 2018b.

All code assumes position files are a matrix with structure [number of points, 3] where the three columns are time, x coordinates, y coordinates.

All code assumes clusters are in a structure where each entry of the structure is a different cluster and contains a vector of the cluster spike times.

------------------------------------------------------------


Files are as follows:

accel.m = computes acceleration from position

accerror.m = computes decoding error after decoding acceleration using decodeACC.m

decodeAcc.m = decodes acceration using position and spike times

decodeAccSHIFT.m = allows you to shift decoding in time to see most accurate decoding offset

decodeVel.m = computes velocity from position

decodeVelSHIFT.m = allows you to shift decoding in time to see most accurate decoding offset

spearman_rankresults.m = uses spearman's rho to compute accuracy of decoding

velerror.m = computes decoding error after decoding speed using decodeVel.m

velocity.m = computes velocity from position

%
%   test MinErrSpecShift
%   Irino,T.
%   Created:   1 Nov 21
%   Modified:  1 Nov 21
%   Modified:  2 Nov 21
%

Spec = randn(5,100);

zz = zeros(5,10);

Spec2 = [zz Spec zz zz];
Spec1 = [zz zz Spec zz];
tic
Dspec =DistanceSpecShift(Spec1,Spec2)
toc


% Arthur Rubio, Lucas Riviere, 11/2023
% "Preprocessing of Iris Images for BSIF-Based Biometric Systems:
% Canny Algorithm and Iris Unwrapping", IPOL (Image Processing On Line), 2023, Paris, France.
%
% This code normalizes the image between 0 and 1
%
% Input: I: image
% Output: imnorm: normalized image

function [imnorm] = f_normalisation(I)

I=double(I);
M=max(max(max(I))) ;
m=min(min(min(I))) ;
if M > m
    imnorm = (I - m)./(M - m) ;
else
    imnorm = zeros(size(I));
end
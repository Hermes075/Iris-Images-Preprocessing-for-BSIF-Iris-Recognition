function [imnorm] = f_normalisation(I)

I=double(I);
M=max(max(max(I))) ;
m=min(min(min(I))) ;

imnorm = (I - m)./(M - m) ;

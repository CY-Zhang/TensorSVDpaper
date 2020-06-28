function [X] = k_unfold(T, k)
%This function is an unfolding operation on tensor.
dim = size(T);
if(k==1)
    X = reshape(T,dim(1),[]);
else
    X = reshape(shiftdim(T,k-1),dim(k),[]);
end


end


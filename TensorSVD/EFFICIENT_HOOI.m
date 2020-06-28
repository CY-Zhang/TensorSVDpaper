function [X] = EFFICIENT_HOOI(T, r, max_iter)
%Perform efficient HO-SVD on T with specified rank r.
%r is assumed to be much smaller than p.
%Output the estimated subspace in each mode and the recovered tensor.
if(length(size(T)) ~= length(r))
    error('rank length does not match the dimension!');
end

if(any(size(T)<r))
    X = T;
    return;
end

if(isempty(T))
    X = [];
    return;
end

T0 = T;
p0 = size(T);
d = length(p0);
U = cell(1,d);
X = tensor(T);

p = p0;
for k = 1:d
    [~, p_index] = min(p);
    MT = k_unfold(T,p_index);
    if(size(MT,1)>size(MT,2))
        [Uk, ~] = svd_new(MT, r(p_index));
    else
        [Uk, ~] = eigs(MT*MT', r(p_index));
    end
    U{1,p_index} = Uk;
    X = ttm(X, Uk', p_index);
    T = double(X);
    p(p_index) = inf;
end


iter_count = 0;
T = T0;
while iter_count < max_iter
     iter_count = iter_count + 1;
     for k = 1:d
        Y = tensor(T); 
        minus_k = setdiff(1:d, k);
        for j = 1:d-1
            Y = ttm(Y, U{1,minus_k(j)}', minus_k(j));
        end
        MY = k_unfold(double(Y),k);
        [U{1,k}, ~] = svd_new(MY, r(k));
     end
end

p = p0;
X = tensor(T);
for k = 1:d
    [~, p_index] = min(p);
    X = ttm(X, U{1,p_index}', p_index);
    p(p_index) = inf;
end


for k = 1:d
     X = ttm(X, U{1,k}, k);
end

X = double(X);




end


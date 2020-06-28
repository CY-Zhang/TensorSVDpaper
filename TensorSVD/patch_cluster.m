function [IDX] = patch_cluster(Y, nb_clusters, M, N, w, max_iter)
% Clustering based on Y. The patch size is w * w.

if nargin < 6
    max_iter = 500;
end

sum_z = sum(Y,3);
ima_patchs = spatial_patchization(sum_z, w);


[M2,N2,w2] = size(ima_patchs);
ima_patchs_vect = reshape(ima_patchs,[(M2)*(N2),w2]);
% k-means:
IDX = ceil(nb_clusters*rand(1,(M - w + 1)*(N - w + 1)));
iter_count = 0;
last = 0;
n = size(ima_patchs_vect,1);
while(any(IDX ~= last) && iter_count < max_iter)
    iter_count = iter_count+1;
    E = sparse(1:n,IDX,1,n,nb_clusters,n);  % transform label into indicator matrix.
    center = ima_patchs_vect'*(E*spdiags(1./sum(E,1)',0,nb_clusters,nb_clusters));    % compute center of each cluster
    last = IDX;
%    [~,label] = max(bsxfun(@minus,center'*ima_patchs_vect',0.5*sum(center.^2,1)')); % assign samples to the nearest centers
    [~,IDX] = max(bsxfun(@minus,log(center)'*ima_patchs_vect',sum(center,1)'));
end

end


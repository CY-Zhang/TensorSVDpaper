function [ est ] = NLPCA( Y, nb_clusters, nb_axis, IDX, w, w_3d )
% Perform NLPCA to denoise.
% Y is the input Poisson noise, IDX is the clustering index for each
% 2D-patch. w and w_3d are the patch size.
[M, N, P] = size(Y);

IDX_int = repmat(IDX,1,(P-w_3d+1));
ima_patchs = new_spatial_patchization_cube_3d(Y,w,w_3d);
ima_patchs_vect = reshape(ima_patchs,[(M-w+1)*(N-w+1)*(P-w_3d+1),w*w*w_3d]); 
clear ima_patchs

paras_r = nb_axis;

final_estimate = zeros(size(ima_patchs_vect));
indexes = cell(nb_clusters,1);
size_cluster = zeros(nb_clusters,1);
for i = 1:nb_clusters
    indexes{i} = find(IDX_int == i); % finds the location in IDX for a specific cluster number
    size_cluster(i) = size((indexes{i}),2); % number of patches in each cluster
end


for k = 1:(nb_clusters)
    % this finds all the patches in a specific cluster and inserts
    temp_clusters = ima_patchs_vect(indexes{k},:);
    [utmp,stmp,vtmp] = svd_new(temp_clusters,paras_r);
    %final_estimate(indexes{k},:) = exp(utmp*stmp*vtmp');
    final_estimate(indexes{k},:) = utmp*stmp*vtmp';
end

% Reproject and Average:
ima_fil = new_reprojection_UWA_cube_3d(final_estimate,w,w_3d,M,N,P);

ones_matrix = ones((M-w+1)*(N-w+1)*(P-w_3d+1),w*w*(w_3d)); 
normalization_cube = new_reprojection_UWA_cube_3d(ones_matrix,w,w_3d,M,N,P); 
est = ima_fil./normalization_cube; 

end


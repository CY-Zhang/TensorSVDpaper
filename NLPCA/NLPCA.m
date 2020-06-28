
load ../Simulation_truth_STO_slice_10_cropped_100layers.mat
datacube_truth = readNPY('../Simulation_truth_STO_slice_10_cropped_100layers_truth.npy');
ima_nse_poiss = datacube;

%% Parameters:

param.Patch_width=14;
param.Patch_width_3d=5;
param.nb_axis=10; 
param.nb_clusters=5;
param.eps_stop=1e-1; %loop stoping criterion
param.epsilon_cond=1e-3; %condition number for Hessian inver
param.double_iteration=0;%1 or 2 pass of the whole algorithm
param.nb_iterations=4;
param.bandwith_smooth=2;
param.sub_factor=2;
param.big_cluster1=1;% special case for the biggest cluster 1st pass
param.big_cluster2=1;% special case for the biggest cluster 2nd pass
param.cste=70;
param.func_tau=@(X) lasso_tau(X{1},X{2},param.cste);
param.parallel = 0; % cannot use parallel in compiled exe
param.SPIRALTAP = 0; % 0/1 determines if Newton's method is used (0 is recommended)

%% computation
tic
ima_fil=denoise_poisson_kmeans_poisson_PCA_l1_4d_cube_3d(ima_nse_poiss,param);
toc
fprintf("PSNR: %.2f, SSIM: %.2f\n", AveragePSNR(ima_fil, datacube_truth), AverageSSIM(ima_fil, datacube_truth));

%% Caluculate average PSNR from image stack
% input: denosied image stack
% ref: truth image stack
function avg_psnr = AveragePSNR(input, ref)
    avg_psnr = 0;
    for i=1:size(input,3)
        avg_psnr = avg_psnr + psnr(input(:,:,i),ref(:,:,i));
    end
    avg_psnr = avg_psnr / size(input,3);
end

%% Caluculate average SSIM from image stack
% input: denosied image stack
% ref: truth image stack
function avg_ssim = AverageSSIM(input, ref)
    avg_ssim = 0;
    for i=1:size(input,3)
        avg_ssim = avg_ssim + ssim(input(:,:,i),ref(:,:,i));
    end
    avg_ssim = avg_ssim / size(input,3);
end
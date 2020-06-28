%% Setup file names
clearvars
FPS_list = [1000,2000,4000,6000,8000,10000,20000,40000];
for i=1:size(FPS_list,2)
    FPS = FPS_list(i);
    fprintf(num2str(FPS));
    filename = strcat('../../SimulationData/DenoiseInput_cropped/SiDislocation/Simulation_noisy_SiDisl_slice_5_',num2str(FPS),'FPS_cropped_100layers.mat');
    truthname = strcat('../../SimulationData/DenoiseInput_cropped/SiDislocation/Simulation_truth_SiDisl_slice_5_',num2str(FPS),'FPS_cropped_100layers.npy');
    BM4Dname = strcat('../../SimulationData/DenoiseOutput_cropped/SiDislocation/Simulation_BM4D_SiDisl_slice_5_',num2str(FPS),'FPS_cropped_100layers.mat');
    Tensorname = strcat('../../SimulationData/DenoiseOutput_cropped/SiDislocation/Simulation_tensor_SiDisl_slice_5_',num2str(FPS),'FPS_cropped_100layers.mat');
    NLPCAname = strcat('../../SimulationData/DenoiseOutput_cropped/SiDislocation/Simulation_NLPCA_SiDisl_slice_5_',num2str(FPS),'FPS_cropped_100layers.mat');

%% load files
addpath( '../tensor_toolbox-master/');
load(filename);
datacube = double(datacube);
datacube_truth = readNPY(truthname);
% let datacube to be the variable that stores the observation data.

%% BM4D
addpath('../BM4D/');
N2 = 32;
Nstep = 2;
Ns = 23;
lambda_thr4D = 4;
tau_match = 0.1;
N1 = 4;
[est_BM4D, sigma_est] = bm4d(datacube, 'Gauss', 0, 'np', 1, 1);

%% Tensor method:
% You need to install Tensor Toolbox to run the algorithm (https://www.tensortoolbox.org/).
addpath( '../tensor_toolbox-master/');
r = [5 5 9]; %tensor rank, this is the only tuning parameter.
tic;
est_HOOI = EFFICIENT_HOOI(datacube, r, 10);
fprintf("Running time for HOOI: %.2f seconds\n", toc);

%% NLPCA
% following are tuning parameters:
[M,N,P] = size(datacube);
w = 12; % path size in x and y
w_3d = 100; % patch size in z
nb_clusters = 10; % number of clusterstic;
nb_axis = 10; % number of axis in the PCA step, won't change patch step.
tic;
IDX = patch_cluster(datacube, nb_clusters, M, N, w);
est_NLPCA = NLPCA(datacube, nb_clusters, nb_axis, IDX, w, w_3d);
toc;
fprintf("Running time for NLPCA: %.2f seconds\n", toc);

%% Quantify the difference
% 
fprintf("BM4D: %.2f, NLPCA: %.2f, Tensor SVD: %.2f\n", AveragePSNR(est_BM4D, datacube_truth), AveragePSNR(est_NLPCA, datacube_truth), AveragePSNR(est_HOOI, datacube_truth));
fprintf("BM4D: %.2f, NLPCA: %.2f, Tensor SVD: %.2f\n", AverageSSIM(est_BM4D, datacube_truth), AverageSSIM(est_NLPCA, datacube_truth), AverageSSIM(est_HOOI, datacube_truth));
fprintf("%d FPS: %.2f\n",FPS,AveragePSNR(est_HOOI, datacube_truth));
%% Save results
save(BM4Dname, 'est_BM4D');
save(NLPCAname, 'est_NLPCA');
save(Tensorname, 'est_HOOI');

end
%% Visualizations
% ha = tight_subplot(3,10,[.03 0.01],[.01 .01],[.01 .01]);
% for slice = 1:10
%     axes(ha(slice)); 
%     imagesc(datacube(:,:,slice));axis off;
% end
% for slice = 1:10
%     axes(ha(slice + 10)); 
%     imagesc(est_HOOI(:,:,slice));axis off;
% end
% for slice = 1:10
%     axes(ha(slice + 20)); 
%     imagesc(est_NLPCA(:,:,slice));axis off;
% end
% 
% % visulizations from Rungang
% ha = tight_subplot(3,10,[.03 0.01],[.01 .01],[.01 .01]);
% c = 5;
% for slice = 1:10
%     axes(ha(slice)); 
%     imagesc(datacube(:,:,slice), [0 c]);axis off;
% end
% for slice = 1:10
%     axes(ha(slice + 10)); 
%     imagesc(est_HOOI(:,:,slice), [0 c]);axis off;
% end
% for slice = 1:10
%     axes(ha(slice + 20)); 
%     imagesc(est_NLPCA(:,:,slice), [0 c]);axis off;
% end

%% Caluculate average PSNR from image stack
% input: denosied image stack
% ref: truth image stack
function avg_psnr = AveragePSNR(input, ref)
    avg_psnr = 0;
    for i=1:size(input,1)
        for j = 1:size(input,2)
            ref_frame = reshape(ref(i,j,:),[10,10]);
            input_frame = reshape(input(i,j,:),[10,10]);
            avg_psnr = avg_psnr + psnr(input_frame,ref_frame,max(ref(i,j,:)));
        end
    end
    avg_psnr = avg_psnr / size(input,1) / size(input,2);
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
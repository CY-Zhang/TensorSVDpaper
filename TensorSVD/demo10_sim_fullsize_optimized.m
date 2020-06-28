clearvars
addpath( '../tensor_toolbox-master/');

%% Load data with different frame rates
FPS = 10000;
filename = strcat('../../SimulationData/DenoiseInput_fullsize/SiDislocation/Simulation_noisy_SiDisl_slc5_',num2str(FPS),'FPS.mat');
Tensorname = strcat('../../SimulationData/DenoiseOutput_fullsize/SiDislocation/Simulation_tensor_SiDisl_slc5_',num2str(FPS),'FPS_optimized.mat');
truthname = strcat('../../SimulationData/DenoiseInput_fullsize/SiDislocation/Simulation_truth_SiDisl_slc5_',num2str(FPS),'FPS.npy');

load(filename);
datacube = double(datacube);
datacube_truth = readNPY(truthname);

%% Determine denoising ranks using scree plots
% X = k_unfold(datacube, 1); % change 1 to 2 or 3 for different mode
% Y = X*X';
% e = eig(Y);
% e = sqrt(e);
% e = real(e);
% plot(log(flip(e)));

%% Run tensor SVD
r = [23 23 75]; % rank for Si dislocation data
tic;
est_HOOI = EFFICIENT_HOOI(datacube, r, 10);
fprintf("Running time for HOOI: %.2f seconds\n", toc);
fprintf(num2str(AveragePSNR(est_HOOI,datacube_truth)));
fprintf("\n");
% use -v 7.3 for dataset larger than 2GB, 114x114 is fine
save(Tensorname,'est_HOOI');

%% Caluculate average PSNR from image stack
% input: denosied image stack
% ref: truth image stack
function avg_psnr = AveragePSNR(input, ref)
    avg_psnr = 0;
    for i=1:size(input,1)
        for j = 1:size(input,2)
            ref_frame = reshape(ref(i,j,:),[128,128]);
            input_frame = reshape(input(i,j,:),[128,128]);
            avg_psnr = avg_psnr + psnr(input_frame,ref_frame,max(ref(i,j,:)));
        end
    end
    avg_psnr = avg_psnr / size(input,1) / size(input,2);
end
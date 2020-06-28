clearvars
addpath( '../tensor_toolbox-master/');

filename = strcat('Simulation_noisy_SiDisl_slc5_1000FPS.mat');
Tensorname = strcat('Simulation_tensor_SiDisl_slc5_1000FPS.mat');
truthname = strcat('Simulation_truth_SiDisl_slc5_1000FPS.npy');

%% load files
load(filename);
datacube = double(datacube);
datacube = reshape(datacube,[114,114,128,128]);
datacube_truth = readNPY(truthname);
%% Tensor method:
% You need to install Tensor Toolbox to run the algorithm (https://www.tensortoolbox.org/).
r = [32 32 24 24]; %tensor rank, this is the only tuning parameter.
tic;
est_HOOI = EFFICIENT_HOOI(datacube, r, 2);
fprintf("Running time for HOOI: %.2f seconds\n", toc);
fprintf(num2str(AveragePSNR(est_HOOI,datacube_truth)));
%     fprintf("\n");
% use -v 7.3 for dataset larger than 2GB, 114x114 is fine
% save(Tensorname,'est_HOOI');
    
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
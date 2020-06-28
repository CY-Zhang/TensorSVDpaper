clearvars
addpath( '../tensor_toolbox-master/');
FPS_list = [1000,2000,4000,6000,8000,10000,20000,40000];
FPS_list = [1000];
for i=1:size(FPS_list,2)
    FPS = FPS_list(i);
    fprintf(num2str(FPS));
    % Si dislocation case
    filename = strcat('../../SimulationData/DenoiseInput_fullsize/SiDislocation/Simulation_noisy_SiDisl_slc5_',num2str(FPS),'FPS.mat');
    Tensorname = strcat('../../SimulationData/DenoiseOutput_fullsize/SiDislocation/Simulation_tensor_SiDisl_slc5_',num2str(FPS),'FPS.mat');
    truthname = strcat('../../SimulationData/DenoiseInput_fullsize/SiDislocation/Simulation_truth_SiDisl_slc5_',num2str(FPS),'FPS.npy');
    % STO case
%     filename = strcat('../../SimulationData/DenoiseInput_fullsize/STO/Simulation_noisy_STO_slice_5_',num2str(FPS),'FPS_fullsize.mat');
%     Tensorname = strcat('../../SimulationData/DenoiseOutput_fullsize/STO/Simulation_tensor_STO_slice_5_',num2str(FPS),'FPS_fullsize.mat');
%     truthname = strcat('../../SimulationData/DenoiseInput_fullsize/STO/Simulation_truth_STO_slice_5_',num2str(FPS),'FPS_fullsize.npy');

    %% load files
    load(filename);
    datacube = double(datacube);
    datacube_truth = readNPY(truthname);
    
    %% Tensor method:
    % You need to install Tensor Toolbox to run the algorithm (https://www.tensortoolbox.org/).
    r = [33 30 185]; % rank for Si dislocation data
%     r = [7 7 30]; % rank for STO data
    tic;
    est_HOOI = EFFICIENT_HOOI(datacube, r, 10);
    fprintf("Running time for HOOI: %.2f seconds\n", toc);
%     fprintf(num2str(AveragePSNR(est_HOOI,datacube_truth)));
%     fprintf("\n");
    % use -v 7.3 for dataset larger than 2GB, 114x114 is fine
    save(Tensorname,'est_HOOI');
end

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
%% load files
addpath( '../tensor_toolbox-master/');
load('Experiment_noisy_LiZnSb.mat');
datacube = double(datacube);
% datacube_truth = readNPY('Simulation_truth_SiDisl_slc5_10000FPS.npy');

%% Tensor method:
result_list = zeros(3,20);
r = [12 12 70]; %tensor rank, this is the only tuning parameter.
for iter=0:10
% You need to install Tensor Toolbox to run the algorithm (https://www.tensortoolbox.org/).
tic;
est_HOOI = EFFICIENT_HOOI(datacube, r, iter);
result_list(1,iter+1) = toc; % first row for time
result_list(2,iter+1) = norm(est_HOOI(:),'fro');
% result_list(3,iter+1) = AveragePSNR(est_HOOI, datacube_truth);
fprintf("%d Iterations: %d sec, %.2f Fro norm, %.2f dB \n", iter, result_list(1,iter+1),result_list(2,iter+1),result_list(3,iter+1));
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
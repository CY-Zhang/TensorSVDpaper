%% load files
addpath( '../tensor_toolbox-master/');
load('Simulation_noisy_SiDisl_slc5_1000FPS.mat');
datacube = double(datacube);
datacube_truth = readNPY('Simulation_truth_SiDisl_slc5_1000FPS.npy');

% Tensor method with CBED stacks
%% Reshape datacube
datacube_reshape = reshape(datacube,[114,114,128,128]);
datacube_reshape = reshape(datacube_reshape,[114*114,128,128]);
datacube_reshape = permute(datacube_reshape,[2 3 1]);

datacube_truth = reshape(datacube_truth,[114,114,128,128]);
datacube_truth = reshape(datacube_truth,[114*114,128,128]);
datacube_truth = permute(datacube_truth,[2 3 1]);

%% Draw scree plot on the new data
% X = k_unfold(datacube_reshape, 3); % change 1 to 2 or 3 for different mode
% Y = X*X';
% e = eig(Y);
% scree = 1 - (cumsum(e)/sum(e));
% e = sqrt(e);
% plot(log(flip(e)));
% plot(0:size(X,1), [1 scree']);
%% Run tensor SVD, with parameter search
for i=24:24
    for j=78:78
% You need to install Tensor Toolbox to run the algorithm (https://www.tensortoolbox.org/).
        if j > i*i
            continue
        end
        r = [i i j];
        tic;
        est_HOOI = EFFICIENT_HOOI(datacube_reshape, r, 10);
        fprintf(num2str(r));
        fprintf("\n Running time : %.2f sec, PSNR : %.2f dB\n", toc, AveragePSNR_newOrder(est_HOOI, datacube_truth));
    end
end

%% Quantify result in terms of PSNR
% fprintf(AveragePSNR_newOrder(est_HOOI, datacube_truth));

%% Save result
% save('Experiment_tensor_LiZnSB_12-70.mat','est_HOOI','-v7.3');

%% Caluculate average PSNR from image stack
% input: denosied image stack
% ref: truth image stack
function avg_psnr = AveragePSNR_newOrder(input, ref)
    avg_psnr = 0;
    for i=1:size(input,3)
        ref_frame = ref(:,:,i);
        input_frame = input(:,:,i);
        avg_psnr = avg_psnr + psnr(input_frame,ref_frame,max(max(ref(:,:,i))));
    end
    avg_psnr = avg_psnr / size(input,3);
end
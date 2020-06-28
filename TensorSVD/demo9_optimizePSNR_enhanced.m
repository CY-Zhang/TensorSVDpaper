% This script is used to refine the optimal rank based on output PSNR using
% fminsearch function in Matlab

clear datacube datacube_truth est_HOOI; % clear three large datasets
addpath( '../tensor_toolbox-master/');
datacube_truth = readNPY('..\..\SimulationData\DenoiseInput_fullsize\SiDislocation\Simulation_truth_SiDisl_slc5_40000FPS.npy');
load ..\..\SimulationData\DenoiseInput_fullsize\SiDislocation\Simulation_noisy_SiDisl_slc5_40000FPS.mat
datacube = double(datacube);
% let datacube to be the variable that stores the observation data.

%% Shell function that optimize PSNR value
fun = @(b) tensorSVD(b(1),b(2),b(3),datacube, datacube_truth);
options = optimset('Display','iter','PlotFcns',@optimplotfval, 'TolFun',0.05);
% as Matlab fminsearch tends to use small step size, use 1/10 of the rank
% as input for optimization
b_guess = [2.3 2.3 3.5];
b_min = fminsearch(fun, b_guess, options);

%% Function that run tensor SVD with given rank and data
% return inf if parameters does not satisfy criteria, otherwise return
% negative PSNR
function PSNR = tensorSVD(i,j,k, input, truth)
    i = round(i*10);
    j = round(j*10);
    k = round(k*10);
    if i>j*k || j>1*k || k>i*j
        PSNR = Inf;
    else
        % only run 1 HOOI iteration for a faster convergence
        est_HOOI = EFFICIENT_HOOI(input,[i j k],1);
        PSNR = -AveragePSNR(est_HOOI, truth);
    end
end

%% Caluculate average PSNR from image stack
% input: denosied image stack
% ref: truth image stack
function avg_psnr = AveragePSNR(input, ref)
    avg_psnr = 0;
    k_size = sqrt(size(input,3));
    for i=1:size(input,1)
        for j = 1:size(input,2)
            ref_frame = reshape(ref(i,j,:),[k_size,k_size]);
            input_frame = reshape(input(i,j,:),[k_size,k_size]);
            avg_psnr = avg_psnr + psnr(input_frame,ref_frame,max(ref(i,j,:)));
        end
    end
    avg_psnr = avg_psnr / size(input,1) / size(input,2);
end
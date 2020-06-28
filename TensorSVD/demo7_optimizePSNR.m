% This script is used to find the optimal rank based on output PSNR
% Do a rough search over a wide parameter space before using demo10 for
% fine search with fminsearch function

clear datacube datacube_truth est_HOOI; % clear three large datasets
addpath( '../tensor_toolbox-master/');
datacube_truth = readNPY('..\..\SimulationData\DenoiseInput_fullsize\STO\Simulation_truth_STO_slice_5_1000FPS_fullsize.npy');
load ..\..\SimulationData\DenoiseInput_fullsize\STO\Simulation_noisy_STO_slice_5_1000FPS_fullsize.mat
datacube = double(datacube);
% let datacube to be the variable that stores the observation data.

%% Tensor method:
PSNR = zeros(20,20);
maxPSNR = -Inf;
r_min = [0 0 0];
% You need to install Tensor Toolbox to run the algorithm (https://www.tensortoolbox.org/).
for i=4:12
    for j=4:12
        for k =20:2:40
            if k > i*j
                continue
            end
            r = [i j k];
            tic;
            est_HOOI = EFFICIENT_HOOI(datacube, r, 1);
            PSNR(i,j,k) = AveragePSNR(est_HOOI, datacube_truth);
            if PSNR(i,j,k) > maxPSNR
                maxPSNR = PSNR(i,j,k);
                r_min = [i j k];
                % print result if optimal rank got renewed
                fprintf('Optimal rank renew: %d, %d, %d, PSNR = %.2f\n',i,j,k, PSNR(i,j,k));
            end
    %         fprintf("Running time for HOOI: %.2f seconds\n", toc);
%             fprintf('i = %d, j = %d, k = %d, psnr = %.4f, time = %.2f \n', i, j, k, PSNR(i,j,k),toc);
        end
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
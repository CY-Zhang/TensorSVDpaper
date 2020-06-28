%% Setup file names
clearvars
FPS = 1000;
filename = strcat('../../SimulationData/DenoiseInput_cropped/SiDislocation/Simulation_noisy_SiDisl_slice_5_',num2str(FPS),'FPS_cropped_100layers.mat');
truthname = strcat('../../SimulationData/DenoiseInput_cropped/SiDislocation/Simulation_truth_SiDisl_slice_5_',num2str(FPS),'FPS_cropped_100layers.npy');

%% load files
addpath('../BM4D/');
addpath( '../tensor_toolbox-master/');
load(filename);
datacube = double(datacube);
datacube_truth = readNPY(truthname);

%% BM4D
addpath('D:/2020/TensorSVD/Comparison/BM4D/');
N1 = 4;
N2 = 32;
Nstep = 2;
Ns = 23;
lambda_thr4D = 4;
tau_match = 0.1;
for Ns = 32:2:50
    [est_BM4D, sigma_est] = bm4d_tunable(datacube, 'Gauss', 0, 'np', 1, 0, N1, N2, Nstep, Ns, lambda_thr4D,tau_match);
    fprintf("Ns: %d, PSNR: %.2f.\n",Ns, AveragePSNR(est_BM4D, datacube_truth));
end



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

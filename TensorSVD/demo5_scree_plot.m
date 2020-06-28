%% load files
addpath( '../tensor_toolbox-master/');
% load('Simulation_noisy_SiDisl_slc5_1000FPS.mat');
load('..\..\SimulationData\DenoiseInput_fullsize\SiDislocation\Simulation_noisy_SiDisl_slc5_1000FPS.mat');
datacube = double(datacube);
% datacube = real(datacube);

%%
% datacube = readNPY('Simulation_truth_STO_slice_5_1000FPS_fullsize.npy');
%%
tic
X = k_unfold(datacube, 1); % change 1 to 2 or 3 for different mode
Y = X*X';
e = eig(Y);
toc
scree = 1 - (cumsum(e)/sum(e));
e = sqrt(e);
plot(log(flip(e)));
% plot(0:size(X,1), [1 scree']);
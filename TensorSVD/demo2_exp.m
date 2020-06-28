%% load files
addpath( '../tensor_toolbox-master/');
load('../../ExperimentData/RawData/Experiment_noisy_LiZnSb.mat');
datacube = double(datacube);

%% Tensor method:

% profile -memory on


% You need to install Tensor Toolbox to run the algorithm (https://www.tensortoolbox.org/).
r = [35 38 180]; %tensor rank, this is the only tuning parameter.

tic;
est_HOOI = EFFICIENT_HOOI(datacube, r, 1);
fprintf("Running time for HOOI: %.2f seconds\n", toc);

% profile off
% profile report;
% p = profile('info');
% 
% print(p.FunctionTable(1).PeakMem);
% print(p.FunctionTable(1).TotalTime);


%% Save result
save('Experiment_tensor_LiZnSb_35-38-180.mat','est_HOOI','-v7.3');
%% This script computes pairwise LDA classification for directories of test and training


%% Set the directories for test and training data
trainDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
testDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
targetClasses = {'34', '35'};
% targetClassifiers = {'LDA', 'ARRLS'};
targetClassifiers = {'ARRLSMod', 'ARRLSimb'};
params = struct();

%% Get the full paths of test and training files
trainPaths = getFiles('FILES', trainDir, '.mat');
testPaths = getFiles('FILES', testDir, '.mat');
rng('default'); % to reproduce results, keep use the same random seed

%% Perform the classification
for n = 1%:length(targetClassifiers)
    for k = 1%:length(targetClasses)
      outPath = [outPathBase '_' targetClassifiers{n} '_' targetClasses{k}]; 
      batchClassify(testPaths, trainPaths, outPath, ...
                    targetClasses{k}, targetClassifiers{n}, params);
    end
end

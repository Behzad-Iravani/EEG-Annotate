%% This annotation example runs the following five batch scripts.
%
%  1) Preprocess
%  2) Feature extraction
%  3) Score estimation1: classification score of sub-window samples
%  4) Score estimation2: annotation score of window samples
%  5) Report
%
%  This script produces the results used for the paper.
%  "Automated annotation for continuous EEG data", Kyung-min Su, W. David Hairston, Kay Robbins, 2016
%  

clear; close all;

%% 1) Preprocess
%  Apply general preprocessings on the raw EEG data
batch_preprocess_highPassNew('Z:\Data 4\annotate\VEP\preprocessedRAW\', ...
             'outPath', '.\tmp\highPass', ...
             'cutoff', 0.5);
batch_preprocess_cleanASR('.\tmp\highPass', ...
             'outPath', '.\tmp\cleanASR', ...
             'burstCriterion', 20);

%% 2) Feature extraction
batch_feature_averagePower('.\tmp\cleanASR', ...
             'outPath', '.\tmp\averagePower', ...
             'targetHeadset', 'biosemi64.sfp', ...
             'subbands', [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32], ...
             'windowLength', 1.0, ...
             'subWindowLength', 0.125, ...
             'step', 0.125);

%% 3) Classification score of sub-window samples
batch_classify_ARRLSs('.\tmp\averagePower', ...  % test data
             '.\tmp\averagePower', ...          % training data
             'outPath', '.\tmp\scoreARRLS', ...
             'targetClass', '35', ...
             'p', 10, ...
             'sigma', 0.1, ...
             'lambda', 10.0, ...
             'gamma', 1.0, ...
             'ker', 'linear');

%% 4) Annotation score of window samples
batch_annotation('.\tmp\scoreARRLS', ...
             'outPath', '.\output\annotation', ...
             'excludeSelf', true, ...
             'fHighRecall', false, ...
             'position', 8, ...
             'weights', [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5]);

%%  5) Report
batch_report_recall('.\output\annotation', ...
             'outPath', '.\output\report', ...
             'timinigTolerance', 0:7, ...
             'retrieveNumbs', 100:100:500);
         
%% Done
disp('Done. To save space, you can delete the tmp folder.');
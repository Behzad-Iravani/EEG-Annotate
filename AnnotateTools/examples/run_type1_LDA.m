% % This annotation example runs the following five batch scripts.
% 
%  1) Preprocess
%  2) Feature extraction
%  3) Score estimation1: classification score of sub-window samples
%  4) Score estimation2: annotation score of window samples
%  5) Report
% 
%  Reference:
%  Kyung-min Su, W. David Hairston, Kay Robbins, "Automated annotation for continuous EEG data", 2016
%  
%  Kyung-min Su, The University of Texas at San Antonio, 2016-11-07
% 

clear; close all;

% 0) Parameters
pathIn = 'Z:\Data 3\VEP\VEP_PrepClean_Infomax';   % it is already PREP and ICA processed, otherwise I need to run PREP and ICA
pathTemp = 'D:\temp';
pathOutput = '.\output_type1_LDA_34';  % '35'
trainTargetClass = '34';  % '35'
testTargetClasses = {'34'};  % '35'
className = 'Friend';  % 'Foe'

pop_editoptions('option_single', false, 'option_savetwofiles', false);
rng('default')

% %% 1) Preprocess
% %  Apply general preprocessings on the raw EEG data
% %  Note: the input data is already PREP and ICA processed.
% %  - The test dataset dedicated pre-processes such as fixing the data length of subject 12
% %  - Remove artifacts using the ASR tool
% %
% %  Note: If EEG is not PREPed, apply PREP and ICA here.
% batch_preprocess_VEP_exclusive(pathIn, ...
%              'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2'], ...
%              'boundary', 1);
% batch_preprocess_cleanMARA([pathTemp filesep 'VEP_PREP_ICA_VEP2'], ...
%              'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA']);
% 
% %% 2) Feature extraction
% %  Feature: avearge power of subbands and subwindows
% %  Note: to process different headsets data in the same way, 
% %        it generates new EEG data for the target headset 
% %        and extracts features from the new data.
% batch_feature_averagePower([pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA'], ...
%              'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower'], ...
%              'targetHeadset', 'biosemi64.sfp', ...
%              'subbands', [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32], ...
%              'windowLength', 1.0, ...
%              'subWindowLength', 0.125, ...
%              'step', 0.125);
% 
% %% 3) Classification score of window samples
% %   Using ARRLS classifier or LDA classifier
% %   For training classifiers, use VEP datasets having friend (34) and foe (35) classes
% %   In this test, we use the same (VEP) datasets for training and for test.
% batch_classify_LDA([pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower'], ...  % test data
%              [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower'], ...          % training data
%              'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_' trainTargetClass], ...
%              'targetClass', trainTargetClass, ...
%              'DiscrimType', 'linear', ...       % LDA parameters
%              'Prior', 'empirical', ...          % LDA parameters
%              'fTrainBalance', true);    % Balance training samples
% 
% %% 4) Annotation score of sub-window
% %  Estimate annotation scores from classification scores.
% %  using weighting, zero-out, and fuzzy voting
% batch_annotation([pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_' trainTargetClass], ...
%              'outPath', [pathOutput filesep 'annotScore'], ...
%              'excludeSelf', true, ...
%              'adaptiveCutoff', true, ...
%              'rescaleBeforeCombining', true, ...
%              'position', 8, ...
%              'weights', [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5]);

%%  5) Report
%  Generate reports like precision, recall, and plots
% batch_report_RAP([pathOutput filesep 'annotScore'], ...
%              'outPath', [pathOutput filesep 'report'], ...
%              'targetClasses', testTargetClasses, ...   % hit if it is any one of these class
%              'timinigTolerances', 0:7); 
% batch_report_recall([pathOutput filesep 'annotScore'], ...
%              'outPath', [pathOutput filesep 'report'], ...
%              'targetClasses', testTargetClasses, ...   % hit if it is any one of these class
%              'timinigTolerances', 0:7, ...
%              'retrieveNumbs', 100:100:500); 
% batch_report_precision([pathOutput filesep 'annotScore'], ...
%              'outPath', [pathOutput filesep 'report'], ...
%              'targetClasses', testTargetClasses, ...   % hit if it is any one of these class
%              'timinigTolerances', 0:7, ...
%              'maxAnnotation', 100); 
% batch_plot_allPredictions_VEPevent([pathOutput filesep 'annotScore'], ...
%              'outPath', [pathOutput filesep 'report' filesep 'plotAllScores'], ...
%              'sampleSize', 0.125, ...   % length of one sample
%              'plotLength', 500, ...     % length showed in a plot, 240frames = 30seconds.
%              'plotClasses', {'63', '38', '39'; '33', '34', '35'}, ...
%              'fBinary', false); 
% batch_plot_true_in_wing([pathOutput filesep 'annotScore'], ...
%              'outPath', [pathOutput filesep 'report' filesep 'plotTrueWing'], ...
%              'timingTolerances', 2, ...
%              'offPast', 32, ...
%              'offFuture', 32, ...
%              'titleStr', [className '_No_re_ranking']);   % number of sub-window smaples in each window

%% Done
disp('Done. To save space, you can delete the temp folder.');

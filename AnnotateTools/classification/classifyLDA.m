function [scoreData, ldaObj] = classifyLDA(dataTest, dataTrain, ...
                                           targetClass, params)
%% Classify test data using the LDA classifier


%% Setup the parameters and reporting for the call 
     params = processAnnotateParameters('classifyLDA', nargin, 3, params);

    %% Initialize the return structure
    scoreData = getScoreDataStructure();
    testSamples = dataTest.samples;
    scoreData.trueLabels = dataTest.labels; % it is not binary label. one sample can have more than one class label.

    %% If classifier is not passed, must train
    ldaObj = params.LDAObj;
    if isempty(ldaObj)
        [trainSamples, trainLabels] = getTrainingData(dataTrain, targetClass);
        if params.balanceTrain
            [trainSamples, trainLabels] = balanceOverMinor(trainSamples, trainLabels);
        end
        ldaObj = fitcdiscr(trainSamples', trainLabels, ...
            'DiscrimType', params.LDADiscrimType, 'Prior', params.LDAPrior);
    end
    [predLabels, scores] = predict(ldaObj, testSamples');

    scoreData.predLabels = (predLabels == 1);
    scoreData.initProbs = scores(:, 2);
    scoreData.initCutoff = 0.5;
    % LDA retuns two columns of scores.
    % Each column is the probability to be in each class.
    scoreData.finalScores = scores(: ,2) - 0.5;  % score (the probability of the second class), shift so that it has zero cutoff
    scoreData.finalCutoff = 0;
end
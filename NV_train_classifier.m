%% CLASSIFIER TRAINING on NEUROVISTA data
%
%
clear
close all
clc

% Patients
Patient{1} = '23_002';
Patient{2} = '23_003';
Patient{3} = '23_004';
Patient{4} = '23_005';
Patient{5} = '23_006';
Patient{6} = '23_007';

Patient{7} = '24_001';
Patient{8} = '24_002';
Patient{9} = '24_004';
Patient{10} = '24_005';

Patient{11} = '25_001';
Patient{12} = '25_002';
Patient{13} = '25_003';
Patient{14} = '25_004';
Patient{15} = '25_005';

data_path = 'C:\Users\pkaroly\Dropbox\NV_MATLAB\LL-Prediction\TrainingData\';

for iPt = [3 8 9 10 11 13 15]

%% ALGORITHM PARAMETERS

% data
Nfeatures = 16;         % number of final features to choose
averageSize = 60;       % time in seconds to take average over

% log regression
lambda = 0.5;   % regularization param
MaxIter = 100; % grad descent iterations
featureNormalize = 0;  % pre normalize the features? zero mean unit var

patient = Patient{iPt};
% load data
load([data_path patient 'TrainingSeizures']);
load([data_path patient 'TrainingNonSeizures']);

NSz = size(preIctal,3);
T = size(preIctal,2);
Slide = averageSize/2;
N = 2 * (T-Slide)/averageSize;

% average in chunks
all_data_train = zeros(80,N,2*NSz);
all_data_labels = zeros(N,2*NSz);
for n = 1:N
    ind1 = Slide*(n-1)+1;
    % INTERICTAL
    temp = interIctal(:,ind1:ind1+averageSize-1,:);
    dropouts = interIctalDropouts(ind1:ind1+averageSize-1,:);
    dropouts = averageSize - sum(dropouts == 1);
    if sum(dropouts==0)
        display('removing data')
        invalid = dropouts==0;
        temp(:,:,invalid) = [];
        dropouts(invalid) = [];
        temp = squeeze(sum(temp,2));
        temp = temp ./ repmat(dropouts,80,1);
        temp = [temp repmat(mean(temp,2),1,sum(invalid))];  % need to keep dimensions right
    else
        % take the weighted average by removing the dropouts
        temp = squeeze(sum(temp,2));
        temp = temp ./ repmat(dropouts,80,1);
    end
    all_data_train(:,n,1:NSz) = temp;
    all_data_labels(n,1:NSz) = 0;  %% 0 for non-seizure
    
    % PRE-ICTAL
    temp = preIctal(:,ind1:ind1+averageSize-1,:);
    dropouts = preIctalDropouts(ind1:ind1+averageSize-1,:);
    dropouts = averageSize - sum(dropouts == 1);
    if sum(dropouts==0)
        display('removing pre-ictal data')
        invalid = dropouts==0;
        temp(:,:,invalid) = [];
        dropouts(invalid) = [];
        temp = squeeze(sum(temp,2));
        temp = temp ./ repmat(dropouts,80,1);
        temp = [temp repmat(mean(temp,2),1,sum(invalid))];  % need to keep dimensions right
    else
        % take the weighted average by removing the dropouts
        temp = squeeze(sum(temp,2));
        temp = temp ./ repmat(dropouts,80,1);
    end
    all_data_train(:,n,NSz+1:end) = temp;
    all_data_labels(n,NSz+1:end) = 1;  % 1 for seiuzre
end

% reshape the data
all_data_train = reshape(all_data_train,80,N*2*NSz);
all_data_labels = reshape(all_data_labels,1,N*2*NSz);


%% Independence criteria
% normalize by mean/std
if featureNormalize
    mu = mean(all_data_train,2);
    sigma = std(all_data_train,[],2);
    for n = 1:80
        all_data_train(n,:) = (all_data_train(n,:) - mu(n)) ./ sigma(n);
    end
end
% narrow feature vector down to 16 features
iFeatures = rankfeatures(all_data_train,all_data_labels,'Criterion','entropy');
iFeatures = iFeatures(1:Nfeatures);

% NEED TO RE-SORT THE FEATURES
iFeatures = sort(iFeatures);
% get the mean & std
if featureNormalize
    Mu = mu(iFeatures);
    Sigma = sigma(iFeatures);
end

%% Train Logistic Regression
all_data_train = all_data_train(iFeatures,:);
[W_base,~,~] = logistic_regression_fit(all_data_train',[],all_data_labels,[],MaxIter,lambda,0);


Pobs = sum(all_data_labels) / length(all_data_labels);

%% save the results
if featureNormalize
    save([patient 'Classifier'],'W_base','featureNormalize','Pobs','iFeatures','Nfeatures','Mu','Sigma');
else
    save([patient 'Classifier'],'W_base','featureNormalize','Pobs','iFeatures','Nfeatures');
end

end

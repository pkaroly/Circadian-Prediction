%% CLASSIFIER TRAINING on NEUROVISTA data
%
%
clear
close all
clc

iPt = 15;

% iCh = [6 10 16];  %3 
% iCh = [4 8 16];    %8
% iCh = [5 12 16];   % 9
% iCh = [7 10 14];  % 10
% iCh = [2 9 11];  % 11
% iCh = [1 6 9];  % 13
% iCh = [3 4 15];  % 15

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

% data_path = 'C:\Users\pkaroly\Dropbox\NV_MATLAB\LL-Prediction\';
data_path = 'C:\Users\pkaro\Dropbox\NV_MATLAB\LL-Prediction\TrainingData_v1\';

%% ALGORITHM PARAMETERS

preIctalNull = 0;
interIctalNull = 0;

% data
Nfeatures = 16;         % number of final features to choose
averageSize = 60;       % time in seconds to take average over

% cross validation
Nfolds = 10;                 % number of cross validations (at the moment using randperm)
test_percent = 1/Nfolds;     % size of test percent

% log regression
lambda = 0.5;   % regularization param
MaxIter = 100; % grad descent iterations
featureNormalize =  1;  % pre normalize the features? zero mean unit var

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
    if sum(sum(sum(isnan(temp))))
        display('update code')
        return;
    end
    dropouts = interIctalDropouts(ind1:ind1+averageSize-1,:);
    dropouts = averageSize - sum(dropouts == 1);
    if sum(dropouts==0)
        display('removing data')
        invalid = dropouts==0;
         interIctalNull = interIctalNull + sum(invalid);
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

    all_data_train(:,n,1:2:2*NSz) = temp;
    all_data_labels(n,1:2:2*NSz) = 0;  %% 0 for non-seizure    
    
    % PRE-ICTAL
    temp = preIctal(:,ind1:ind1+averageSize-1,:);

    dropouts = preIctalDropouts(ind1:ind1+averageSize-1,:);
    dropouts = averageSize - sum(dropouts == 1);
    if sum(dropouts==0)
        display('removing pre-ictal data')
        invalid = dropouts==0;
        preIctalNull = preIctalNull + sum(invalid);
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

    all_data_train(:,n,2:2:end) = temp;
    all_data_labels(n,2:2:end) = 1;  % 1 for seiuzre
end

% reshape the data
all_data_train = reshape(all_data_train,80,N*2*NSz);
all_data_labels = reshape(all_data_labels,1,N*2*NSz);

% check removals
fprintf('removed %.2f percent of pre ictal data\n',100*preIctalNull / (NSz*N));
fprintf('removed %.2f percent of inter ictal data\n',100*interIctalNull / (NSz*N));

%% Independence criteria

if featureNormalize
    mu = mean(all_data_train,2);
    sigma = std(all_data_train,[],2);
    for n = 1:80
        all_data_train(n,:) = (all_data_train(n,:) - mu(n)) ./ sigma(n);
    end
end

%% Train Logistic Regression
% all_data_train = all_data_train(iFeatures,:);
N = length(all_data_train);
Ntest = round(test_percent*N / 10) * 10;

% intialize AUC values for each fold
AUC = zeros(1,Nfolds);
Acc = AUC;
test_ind = 1:N;
rankFeatures = zeros(Nfolds,80);
% 10 fold cross validation (w/o replacement)
for n = 1:Nfolds
    
    % index for test set
    if n == Nfolds
        this_fold = test_ind(Ntest*(n-1)+1:end);
    else
        this_fold = test_ind(Ntest*(n-1)+1:Ntest*n);
    end
    % test set
    data_test = all_data_train(:,this_fold);
    data_test_labels = all_data_labels(this_fold);
    % intialize training data to everything
    data_train = all_data_train;
    data_train(:,this_fold) = [];
    data_train_labels = all_data_labels;
    data_train_labels(this_fold) = [];
    
%     feature selection
    [iFeatures,Z] = rankfeatures(data_train,data_train_labels,'Criterion','entropy');
    [~,rankFeatures(n,:)] = sort(iFeatures);  % save rank
    iFeatures = iFeatures(1:Nfeatures);
%     NEED TO RE-SORT THE FEATURES
    iFeatures = sort(iFeatures);

%     Ch1 = iCh(1):16:80;
%     Ch2 = iCh(2):16:80;
%     Ch3 = iCh(3):16:80;    
%     iFeatures = [Ch1 Ch2 Ch3];

    % keep the top 16 in the data
    data_train = data_train(iFeatures,:);
    data_test = data_test(iFeatures,:);
    
    [W,out,AUC(n)] = logistic_regression_fit(data_train',data_test',data_train_labels,...
        data_test_labels,MaxIter,lambda,0);
    % ACCURACY
%     Acc(n) = (sum(out >= 0.5 & data_test_labels == 1) + sum(out < 0.5 & data_test_labels == 0)) / length(data_test_labels);
    % SENSITIVITY
    Acc(n) = sum(out >= 0.5 & data_test_labels == 1) / sum(data_test_labels == 1);
    fprintf('cross validation fold %d ... \n',n)
    
end

fprintf('\n average AUC is: %.3f \n',mean(AUC))
fprintf('\n average sensitivity is: %.3f \n',mean(Acc))

%% plotting the data
close all
[coeff,score,~,~,explained] = pca(all_data_train');

% make a 3d plot
figure; 
hold on;
% subplot(121); 
p(1) = plot(score(all_data_labels == 1,1),score(all_data_labels == 1,2),'.','markersize',10,'markeredgecolor',[204 0 0 ]/255,'markerfacecolor',[204 0 0 ]/255);
p(2) = plot(score(all_data_labels == 0,1),score(all_data_labels == 0,2),'.','markersize',10,'markerfacecolor',[0 76 153]/255,'markeredgecolor',[0 76 153]/255);
% set(gca,'xlim',[-25 15],'ylim',[-5 15],'xtick',[],'ytick',[]);
legend(p,{'pre-ictal','inter-ictal'},'box','off');
xlabel(sprintf('PC 1 (%.2f%%)',explained(1)));
ylabel(sprintf('PC 2 (%.2f%%)',explained(2)));
title(sprintf('average AUC: %.2f',mean(AUC)));

% subplot(122); hold on;
% plot(score(all_data_labels == 1,2),score(all_data_labels == 1,3),'.','markersize',10,'markeredgecolor',[204 0 0 ]/255,'markerfacecolor',[204 0 0 ]/255);
% plot(score(all_data_labels == 0,2),score(all_data_labels == 0,3),'.','markersize',10,'markerfacecolor',[0 76 153]/255,'markeredgecolor',[0 76 153]/255);
% set(gca,'xlim',[-5 15],'ylim',[-10 10]);

save([patient '_Features'],'rankFeatures');

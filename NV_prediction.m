%%
% %
close all
clear
clc

iPt = 3;

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

curPt = Patient{iPt};
% data_path = 'C:\Users\pkaro\Dropbox\NV_MATLAB\LL-Prediction\';
data_path = 'C:\Users\pkaroly\Dropbox\NV_MATLAB\LL-Prediction\';
result_path = [data_path curPt '\'];

% load pt information
load(['Portal Annots/' curPt '_Annots']);
load([data_path 'TrainingData/' curPt 'SzProb']);
load([data_path 'TrainingData/' curPt 'Classifier']);

% dropouts = test what value we get out of the classifier when the input is
% 0
dropout_value = logistic_regression_run(W_base,zeros(1,16),1);


%% algorithm parameters
start_time = 4*4*7;   % (first four months is training period)
segment_length = 24*60*60;  % one day

preIctalTime = 1*60*60;  % for forecasting

% Lead time to include the seizures in seconds
LeadTime = 5*60*60;  % ** CHECK

featureWin = 5;       % time in seconds for feature vec calculation (SECONDS)
featureWinSlide = 1;  % sliding window amount for feature vec calculation (SECONDS)
extraTime = 0.5;        % for filtering artifact (SECONDS)
featureAvWin = 60;    % to average features (SECONDS)

%% initalize
output = dir(result_path);
output = output(3:end);

% get seizure index
ISI = diff(SzTimes) / 1e6;
ISI = [LeadTime+1 ISI];

% ***************** LOOK AT TYPE 3 SEIZURES *****************
remove = SzType == 3;
SzType(remove) = [];
SzDur(remove) = [];
ISI(remove) = [];
SzTimes(remove) = [];

% *********** LOOK AT LEAD SEIZURES ONLY *******************
remove = ISI  < LeadTime;
SzTimes(remove) = [];
SzDur(remove) = [];
SzType(remove) = [];

SzTimes = SzTimes / 1e6;    % get to seconds

N = length(output);

% alert thresholds
tau_w = 60*60/30;
tau_w0 = 3*60/30;
tau_low = 10*60/30;

%% init Brier score
% 1 = log regression
% 2 = circadian weighted log reg
Ndays = ceil(max(SzTimes)/86400);
forecast_size = segment_length/(featureAvWin/2);
Seizures = zeros(1, 86400*Ndays / 30);
Brier = zeros(2,length(Seizures));

%% go through results
for n = 1:N
    
    if strcmp(output(n).name,[curPt 'Classifier.mat'])
        continue;
    end
    load([result_path output(n).name]);
    
    ind = t0/30;
    Brier(1,ind:ind+forecast_size-1) = forecast(1,1:forecast_size);
    Brier(2,ind:ind+forecast_size-1) = forecast(2,1:forecast_size);
    
end

%% set indicator function
SzInd = floor(SzTimes ./ (featureAvWin/2) );  % the 30 s interval that the seizure happens
Seizures(SzInd) = 1;

%% remove irrelevant data
L = min(length(Brier),length(Seizures));
Brier = Brier(:,1:L);
Seizures = Seizures(1:L);

% get rid of training
Brier(:,1:86400*(start_time+1)/(featureAvWin/2)-1) = [];
Seizures(1:86400*(start_time+1)/(featureAvWin/2)-1) = [];

% get rid of dropouts
dropouts = round(Brier(1,:) * 10000) ==  round(10000*dropout_value);
Brier(:,dropouts) = [];
Seizures(dropouts) = [];

% get rid of missing data
missing = Brier(1,:) == 0;
Brier(:,missing) = [];
Seizures(missing) = [];

SzInd = find(Seizures);

%% alert thresholds

% RED ALARM
hi_alert = zeros(2,length(Brier));

hi_thresh(1) = prctile(Brier(1,:),95);
hi_thresh(2) = prctile(Brier(2,:),95);

for n = 1:2
    hiON = find(Brier(n,:) > hi_thresh(n));
    for nn = 1:length(hiON)
        ind = hiON(nn);
        hi_alert(n,ind+1:ind+tau_w) = 1;
    end
end
hi_alert = hi_alert(:,1:length(Brier));

% BLUE ALARM
lo_alert = zeros(2,length(Brier));

lo_thresh(1) = prctile(Brier(1,:),10);
lo_thresh(2) = prctile(Brier(2,:),10);

for n = 1:2
    loON = find(Brier(n,:) < lo_thresh(n));
    for nn = 1:length(loON)
        ind = loON(nn);
        lo_alert(n,ind+1:ind+tau_low) = 1;
    end
end
lo_alert = lo_alert(:,1:length(Brier));

lo_alert(logical(hi_alert)) = 0;
mod_alert = ~hi_alert & ~lo_alert;

%% seizures detected
NSz = length(SzInd);
TP = zeros(2,1);    % for the high alert
FN = zeros(2,1);    % for the low alert
for n = 1:NSz
    
    ind = SzInd(n);
    check = sum(hi_alert(:,ind-tau_w0:ind-1),2);
    TP = TP + (check == tau_w0);
    
    check = sum(lo_alert(:,ind-tau_w0:ind-1),2);
    FN = FN + (check ~= 0);
    
end

%%  statistics
% --------------------------------------------------------------------

rho_mod = sum(mod_alert,2) / length(mod_alert);

% red light
SN = TP / NSz;
rho_red = sum(hi_alert,2) / length(hi_alert);
lambda = -1 ./ tau_w  .* log(1-rho_red);
SNC = 1 - exp(-lambda.*tau_w + (1 - exp(-lambda.*tau_w0)));
p = SN - SNC;


% --------------------------------------------------------------------
% blue light
rho_blue = sum(lo_alert,2) / length(lo_alert);

SN
rho_red
rho_blue
FN

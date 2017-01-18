clear
close all
clc

norm01 = 0;

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

% data_path = 'C:\Users\pkaroly\Dropbox\NV_MATLAB\LL-Prediction\TrainingData\';
mkdir('TrainingData');
data_path = 'TrainingData/';

% for iPt = [3 8 9 10 11 13 15]
for iPt = 6
    
    save_path = [data_path Patient{iPt}];
    
    % when training period ends
    start_test = 200;
    
    
    %% load information
    curPt = Patient{iPt};
    % load([curPt '_DataInfo']);
    % trial_t0 = datenum(MasterTimeKey(1,:));
    load(['Portal Annots/' curPt '_Annots']);
    load('Portal Annots/portalT0');
    trial_t0 = datenum(startDateTime(iPt));
    
    % chron. order
    [SzTimes,I] = sort(SzTimes);
    SzType = SzType(I);
    SzDur = SzDur(I);
    
    % get the circadian time of seizures
    SzCirc = trial_t0 + SzTimes/1e6/86400;
    SzCirc = datevec(SzCirc);
    % for daylight savings
    SzYear = SzCirc(:,1);
    SzMon = SzCirc(:,2);
    SzDate = SzCirc(:,3);
    % seizure TOD
    SzCirc = SzCirc(:,4);
    
    %% shift the daylight savings TOD for each possible year
    
    % 2009/2010
    DaylightSavingsON = SzYear == 2009 & ( SzMon > 10 | (SzMon == 10 & SzDate > 4) );  % 2009 after Oct 4th
    SzCirc(DaylightSavingsON) = SzCirc(DaylightSavingsON) + 1;   % CLOCK FORWARDS
    DaylightSavingsON = SzYear == 2010 & ( SzMon < 4 | (SzMon == 4 & SzDate < 4) );  % 2010 before Apr 4th
    SzCirc(DaylightSavingsON) = SzCirc(DaylightSavingsON) + 1;   % CLOCK FORWARDS
    % 2010/2011
    DaylightSavingsON = SzYear == 2010 & ( SzMon > 10 | (SzMon == 10 & SzDate > 3) );  % 2010 after Oct 3rd
    SzCirc(DaylightSavingsON) = SzCirc(DaylightSavingsON) + 1;   % CLOCK FORWARDS
    DaylightSavingsON = SzYear == 2011 & ( SzMon < 4 | (SzMon == 4 & SzDate < 3) );  % 2010 before Apr 3rd
    SzCirc(DaylightSavingsON) = SzCirc(DaylightSavingsON) + 1;   % CLOCK FORWARDS
    % 2011/2012
    DaylightSavingsON = SzYear == 2011 & ( SzMon > 10 | (SzMon == 10 & SzDate > 2) );  % 2010 after Oct 2nd
    SzCirc(DaylightSavingsON) = SzCirc(DaylightSavingsON) + 1;   % CLOCK FORWARDS
    DaylightSavingsON = SzYear == 2012 & ( SzMon < 4 | (SzMon == 4 & SzDate < 1) );  % 2010 before Apr 1st
    SzCirc(DaylightSavingsON) = SzCirc(DaylightSavingsON) + 1;   % CLOCK FORWARDS
    % 2012/2012
    DaylightSavingsON = SzYear == 2012 & ( SzMon > 10 | (SzMon == 10 & SzDate > 7) );  % 2010 after Oct 7th
    SzCirc(DaylightSavingsON) = SzCirc(DaylightSavingsON) + 1;   % CLOCK FORWARDS
    %%
    
    % remove type threes
    remove = SzType == 3;
    SzType(remove) = [];
    SzTimes(remove) = [];
    SzCirc(remove) = [];
    
    % save seizures within training & test period
    SzDay = ceil(SzTimes/1e6/60/60/24);
    training = SzDay < start_test;
    
    S = sum(SzDay < start_test & SzDay > 100);
    Seizures1 = SzCirc(training);
    Seizures2 = SzCirc(~training);
    
    % create the empirical histogram
    SzHist = hist(Seizures1,0:23);
    SzHist = SzHist + 1;            % need a uniform prior of 1 to avoid any zero probability times
    
    % DOING THE WRAPPED HISTOGRAM
    Kn = 24;         % number of kernels
    Kmean = 0:23;    % kernel centers
    Kbw = 0.6;         % this is the "bandwidth" or std of the Gaussian kernels
    Kgauss = zeros(Kn,Kn);  % these are my distributions
    
    for nn = 1:Kn
        Kgauss(nn,:) = SzHist(nn) * generate_circ_pdf(Kmean(nn),Kmean,1/Kbw);
    end
    % the density is given by the normalized sum of the kernels
    SzPDF = sum(Kgauss); % keep this as raw value so we can iterate the sum
    
    % this is to normalize the area to 1 (ish)
    SzProb = SzHist/trapz(0:23,SzHist);
    SzPDF = SzPDF/trapz(0:23,SzPDF);
    
    M1 = min(SzProb);
    M2 = max(SzProb);
    
    if norm01
        % need to normalize to range [0.1 0.9]
        SzPDF = (M2 - M1) * (SzPDF - min(SzPDF)) ./ (max(SzPDF) - min(SzPDF)) + M1;
    end
    
    save([save_path 'SzProb'],'SzProb','SzPDF','trial_t0')
    
    %% Now pre-compute all the probablity updates
    save_path = [data_path Patient{iPt} 'SzProbAll/'];
    mkdir(save_path);
    SeizureID = zeros(1,length(Seizures2));
    for iSz = 1:length(Seizures2)
        
        % create the empirical histogram
        SzHist = hist([Seizures1 ; Seizures2(1:iSz)],0:23);
        SzHist = SzHist + 1;            % need a uniform prior of 1 to avoid any zero probability times
        % params as above
        Kgauss = zeros(Kn,Kn);  % these are my distributions
        for nn = 1:Kn
            Kgauss(nn,:) = SzHist(nn) * generate_circ_pdf(Kmean(nn),Kmean,1/Kbw);
        end
        % the density is given by the normalized sum of the kernels
        
        SzPDF = sum(Kgauss);
        % this is to normalize the area to 1 (ish)
        SzProb = SzHist/trapz(0:23,SzHist);
        SzPDF = SzPDF/trapz(0:23,SzPDF);
     
        M1 = min(SzProb);
        M2 = max(SzProb);
        
        if norm01
            % need to normalize to range [0.1 0.9]
            SzPDF = (M2 - M1) * (SzPDF - min(SzPDF)) ./ (max(SzPDF) - min(SzPDF)) + M1;
        end
        
        % save according to the number of seizures included in the pdf
        ID = floor(SzTimes(length(Seizures1)+iSz)/1e6);  % use start second of seizure as an identifier
        SeizureID(iSz) = ID;
        save([save_path 'SzProb_' num2str(ID)],'SzProb','SzPDF')
    end
    save([save_path 'SzProb_ID'],'SeizureID');
    
    fprintf('all training seizures: %d\nall test seizures: %d\nbase-rate: %.2f\n',S,length(Seizures2),100 * length(Seizures2) / ((max(SzDay) - 200) * 24))
    
end
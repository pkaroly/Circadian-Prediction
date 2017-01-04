# Seizure-Prediction-TimeOfDay
The code used by Karoly et. al. (2016) Slow Rhythms of Seizures Improve Prediction <br>
Define a log regression classifier using basic features of NeuroVista data for seizure prediction, with output weighted by time of day. <br>

<i>NB most of this code won't run, as it requires my personal login files for the iEEG portal https://www.ieeg.org/, 
as well as information about patients seizure times that is not publicly available. The code is here as a reference for the methods used. Training data and forecast results are also provided. </i>

## CODES

getInterictal: get interictal segments of data from iEEG portal <br>
getSeizures: " " preictal " " <br>
<br>
NV_filters: make filters <br>
NV_seizure_prob: sets up circadian profiles <br>
NV_validate_classifier: 10 fold cross-validation of LR model <br>
NV_train_classifier: train LR model on all data <br>
NV_eval_forecast: works out the Brier scores from probbaility vector
NV_calibrate_forecast: adjusts probability vector based on calibration curve

### other functions
logistic_regression_fit: fits the LR model to training data (code from Andrew Ng, Machine Learning Coursera, https://www.coursera.org/instructor/andrewng) <br>
logistic_regression_run: gets output of LR model given an input feature vector  <br>
calculate_features: gets the correct features given an index (from 1-16) <br>
time_of_day_pdf_estimate(WRAPPED): calculates kernel mixture of von-Mises distribution. Relies on circular statitsics toolbox in MATLAB 
(https://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox--directional-statistics-?requestedDomain=www.mathworks.com)


## FILES
pt_Forecast: contains the probability vector calculated for the entire trial and indicator function


## Other References

[1] Cook, Mark J., et al. "Prediction of seizure likelihood with a long-term, implanted seizure advisory system in patients with drug-resistant epilepsy: a first-in-man study." The Lancet Neurology 12.6 (2013): 563-571. <br>

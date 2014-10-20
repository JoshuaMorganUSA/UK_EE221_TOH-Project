%Threshold Of Hearing characterization program
%Used to determine number of sample points sufficient for use in filter
%design

%Created by: Joshua P. Morgan
%10/2014

%EE221 Experimental Desing Project

%Clear Workspace
close all;

test_mode = 0;   %only plays one pulse of each freq (not flipped).
test_num_sample_points = 10;
test_num_sample_trials = 1; 

%*****TRIAL SETUP****************************
%Enter end point frequencies (Hz)
freq_lower = 1000;
freq_upper = 10000;

%Enter number of sample points for testing. The program will automatically
%test in between adjacent points as well for use in determining
%sufficiency of the sample number. IE (num_sample_points = 10 will actually
%result in 10 + 9 sample poins. 10 for the original sample points and 9
%points in between those 10.

num_sample_points = 10;


%Enter number of trials for each data point. 
num_sample_trials = 5;



%Should the program randomly flip the decay (fade in vs fade out)?
should_rand_flip = 1;
should_always_flip = 0; 


%****CALIBRATION SETUP******
cal_freq = 3500;        %(Hz)
cal_dblevel = -4; 


%*****ANALYSIS SETUP*************************
%How far on either side is acceptable. Ex. entering 1 for db and std 
%means within 1 db or within 1 std on EITHER side of the data point
%for a total acceptance band of 2 db or 2 std

tolerance_db = 1;
tolerance_std = 1;







%*********************************************************
%AUDIO PLAYBACK CONFIGURATION
audio_sample_freq = 44100;  % Sampling rate in Hz
amp_max = .1;  % Amplitude of first tone
dbstep = 1;  %  Decibles of sound attenuation between pulses
int_tone = .2;  %  Tone duration in seconds
int_silent = .2; %  Interval of silence between tones
num = 30;  % number of tones

preview = true;
pre_preview_delay = 0.2;
post_preview_delay = 0.2;
preview_length = 0.3;


%TEST MODE RECONFIGURATION
%Overwrite user values if in test mode
if(test_mode)
    num_sample_points = test_num_sample_points;
    num_sample_trials = test_num_sample_trials;
end




%Create array of sample frequencies to use. 
num_sample_freqs = num_sample_points * 2 - 1;
sample_freqs = [logspace(log10(freq_lower), log10(freq_upper), num_sample_freqs), cal_freq];

%Create array of all frequencies * num_sample_trials. Will be
%num_sample_trials of each sample frequency
trial_freqs = [transpose(repmat(sample_freqs, 1, num_sample_trials))];

%Array to hold trial data. Each column is of form:
%Frequency
%[Trial Data]       (1 x num_sample_trials)
%mean               mean of trial data
%std                standard deviation of trial data               
trial_data = [num2cell(sample_freqs); cell(3, num_sample_freqs + 1)]; %Add one for cal freq


%Run all trials...
trial_freqs_size = size(trial_freqs, 1);
while(trial_freqs_size ~= 0)
     
  %Randomly select sample frequency
  this_trial_index = randi(trial_freqs_size); %Find index of this trial
  this_trial_freq = trial_freqs(this_trial_index, 1);   %This trial frequency
  
  %Find index in data cell array that corresponds to this frequency
  this_data_index = find([trial_data{1,:}] == this_trial_freq, 1);

  %Decide if should randomly flip the decay
  this_should_flip = should_rand_flip * randi([0,1], 1, 1) || should_always_flip;
  
  
  
  %Play preview tone
  if(preview && this_should_flip)
     
      pause(pre_preview_delay)
      play_trial(this_trial_freq, audio_sample_freq, amp_max, 0, preview_length, 0, 1, false);
  end
  
  pause(post_preview_delay);
  
  %Actually play the trial sound (play only one tone in test mode)
  if(~test_mode)    
    play_trial(this_trial_freq, audio_sample_freq, amp_max, dbstep, int_tone, int_silent, num, this_should_flip);
  else         
    play_trial(this_trial_freq, audio_sample_freq, amp_max, dbstep, int_tone, int_silent, 1, false);  
  end
  
  %Get number of pulses the user heard ("counts")
  counts = get_user_counts();
  
  %Add the resulting data to the data array
  trial_data{2, this_data_index} = [trial_data{2, this_data_index}; counts, this_should_flip];
    
  
  %Remove this trial from trial_freqs. It will not be run again.
  trial_freqs(this_trial_index,:) = [];
    
  
  trial_freqs_size = size(trial_freqs, 1);
end

%DATA COLLECTION IS COMPLETE

%Create Vector for saving excel file
save_data = {};

for i = 1:length(trial_data)
   
    temp_freq = [trial_data{1, i}];
    temp_data = [trial_data{2, i}];
    save_data = [save_data, [{'Frequency/Counts'}; temp_freq; num2cell(temp_data(:, 1))]];
    save_data = [save_data, [{'Frequency/Flipped'}; temp_freq; num2cell(temp_data(:, 2))]];
    

end

%disp(save_data)
%Analyze Data
trial_data = analyze_data(trial_data, cal_freq, cal_dblevel, dbstep, tolerance_db, tolerance_std);



%Save raw data to Excel File
delete('data.xls');     %Seems bad, but it works
xlswrite('data', save_data);







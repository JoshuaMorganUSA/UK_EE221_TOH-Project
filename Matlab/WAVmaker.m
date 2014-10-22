audio_sample_freq = 44100;  % Sampling rate in Hz
amp_max = .1;  % Amplitude of first tone
dbstep = 3;  %  Decibles of sound attenuation between pulses
int_tone = .2;  %  Tone duration in seconds
int_silent = .2; %  Interval of silence between tones
num = 30;  % number of tones

lower_frequency = 1000;
upper_frequency = 10000;

sample_points = 19;  %10 test points and 9 in-between points

sample_frequencies = logspace(log10(lower_frequency), log10(upper_frequency), sample_points); %Go ahead and log the points so the graph doesn't
sample_frequencies = [sample_frequencies, 3500];      %Add 3500 Hz for calibration            %need to have a log x-axis.

for i = 1:length(sample_frequencies)	%For however many sample frequencies there are:
    
    signal = autest(sample_frequencies(1,i),audio_sample_freq, amp_max, dbstep, int_tone, int_silent, num);	%Using given autest.m to create
    														%the signal
    wav_filename = strcat(num2str(sample_frequencies(1,i)), '.wav');
    audiowrite(wav_filename, signal, audio_sample_freq);	
    
end


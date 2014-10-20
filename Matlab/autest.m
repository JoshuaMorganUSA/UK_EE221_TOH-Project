function tsig = autest(freq, samp, initamp, dbstep, sint, qint, num)
%
%    tsig = autest(freq, samp, initamp, dbstep, sint, qint, num)
%
%   This function creates a signal composed of a sequence of
%   tones with decreasing amplitudes.
%   freq => Frequency of tone in Hz.
%   Samp => Sampling rate.
%   initamp =>  Initial amplitude of the first tone.
%   dbstep  =>  decibel decrement between amplitude
%                of consecutive tones.
%   sint =>  Time duration (in seconds) of each tone
%             in the sequence.
%   qint =>  Time duration (in seconds) of silence 
%             between each tone.
%   num  =>  Number of tones in the sequence
%
%    Written by Kevin D. Donohue  9-12-96
%    donohue@engr.uky.edu
%               

t = [0:1/samp:sint];             %  Create time axis
sig = initamp*sin(2*pi*freq*t);  %  Create tone

%  Create envelope for tone to gradually increase
%   and decrease.

midpt = floor(length(t)/2);    
env = [0:midpt-1];    
if midpt == ceil(length(t)/2)
   %  If even:
  env = [env, fliplr(env)]/(midpt-1);
else
   % If odd:
  env = [env, midpt, fliplr(env)]/midpt;
end

%  Now create tone with parabolic attack and decay

sig = sqrt(env).*sig;

%  Now concatenate sequence of decreasing tones separated
%  by periods or silence.

dbs = dbstep/20;    %  Decrement for amplitudes
znum = floor(qint*samp);   %  Number of samples
                           %   during silence
zvec = zeros(1,znum);      %  Silent signal

tsig = sig;      %  Initialize vector to concatenate
                 %   sequence
for k=1:num-1,
 tsig = [tsig, zvec, sig/(10^(dbs*k))];
end

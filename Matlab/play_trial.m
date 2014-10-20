function play_trial(freq,sample,amp_max, dbstep, int_tone, int_silent, num, should_flip)

    tsig = autest(freq, sample, amp_max, dbstep, int_tone, int_silent, num);
    
    if(~should_flip)
        soundsc(tsig,sample);
    else
        tsig = flip(tsig);
        soundsc(tsig, sample)
    end
    
end

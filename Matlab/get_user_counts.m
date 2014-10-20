function counts = get_user_counts();

    str = input('How many counts did you hear? ',  's');
    str_num = str2double(str);
    
    %Confirm user   1) Entered something
    %               2) Entered a number
    %               3) That it is an integer
    %               4) That it is greater than 0
    
    while(isempty(str) || isnan(str_num) || mod(str_num, 1) ~= 0 || str_num <= 0)
       
        str = input('You must enter a positive integer: ', 's');
        str_num = str2double(str);
    end
    
    
    counts = str_num;
end
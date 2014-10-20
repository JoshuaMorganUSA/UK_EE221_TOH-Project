
function trial_data = analyze_data(trial_data, cal_freq, cal_dblevel, dbstep, tolerance_db, tolerance_std)
    %*********ANALYZE DATA************

    
    %Calibrate: Convert to db 
    cal_index = find([trial_data{1, :}] == cal_freq, 1);
    
    %Find max counts for cal freq
    cal_max_count = max(trial_data{2, cal_index}(:, 1));
    
    %Remove cal data from trial_data
    trial_data(:, cal_index) = [];
    
    %Convert all data to db. Probably better way to do this
    for i = 1:length(trial_data)
       
        trial_data{2,i} (:, 1) = dbstep * (cal_max_count - trial_data{2,i} (:, 1)) + cal_dblevel;
    end
    
    
    %Calculate standard deviation and mean for each trial frequency
  for i = 1:length(trial_data)

        trial_data{3, i} = mean(trial_data{2, i}(:, 1));
        trial_data{4, i} = std(trial_data{2, i}(:, 1));

    end
    
    %Global standard deviation is average of standard devs from all trials
    global_std = mean([trial_data{4, :}]);
   
    
    %Get data from original test points (IE not the points in between)
    original_test_points =  [[trial_data{1, 1:2:end}];... 
                            [trial_data{3, 1:2:end}];...
                            [trial_data{4, 1:2:end}]];
                        
    %Get data from test mid-points
    mid_test_points =       [[trial_data{1, 2:2:end}];...
                            [trial_data{3, 2:2:end}];...
                            [trial_data{4, 2:2:end}]];
                        
                       

    %Generate linearly interpolated points. %Could've just used the
    %mid_test_points frequencies, but this works and is done. May
    %eventually re-do
    interp_test_points = [];
    %Get x - values
    for i = 1 : length(original_test_points) - 1
       
        %Test point x-value in log middle of 'a' and 'b' is sqrt(a * b)
        interp_test_points = [interp_test_points, sqrt(original_test_points(1, i) * original_test_points(1, i + 1))];
        
    end
    
    %Conctenate y - values
    interp_test_points = [interp_test_points; interp1(original_test_points(1,:),original_test_points(2,:), interp_test_points)];
        
    
    
    %Calculate largest error window (std vs db)
    global_error_band = max([tolerance_std * global_std, tolerance_db]);
    
    
    %Plot Results
    f1 = figure(1)
    
    title('Threshold of Hearing')
    xlabel('Frequency (Hz)')
    ylabel('Threshold (dB)')
 
    
    %Plot original test points
    semilogx(original_test_points(1,:), original_test_points(2,:), 'ko-', 'LineWidth', 2)
    
    hold on
    grid
    
    %Plot mid points determined from linear interpolation
    semilogx(interp_test_points(1,:), interp_test_points(2,:), 'kp', 'MarkerSize', 12, 'MarkerEdgeColor', 'k', 'LineWidth', 1, 'MarkerFaceColor', 'g')
    
    %Plot error bands above and below test points. This represents the max
    %window the actually measured mid point can fall inside
    semilogx(original_test_points(1,:), original_test_points(2,:) + global_error_band, 'r-o', 'LineWidth', 2)
    semilogx(original_test_points(1,:), original_test_points(2,:) - global_error_band, 'r-o', 'LineWidth', 2)
    
    %Plot mid points actually measured during data collection
    semilogx(mid_test_points(1,:), mid_test_points(2,:), '*b', 'MarkerSize', 12, 'LineWidth', 2) 
    
    %Display legend
    legend('Measured Data Points', 'Linearly Interpolated mid points', 'Tolerance band max', 'Tolerance band min', 'Measured mid points', 'Location', 'northoutside')
  
    
    %Save figure(1) as jpg
    saveas(f1, 'data.jpg');
    
    
   
end
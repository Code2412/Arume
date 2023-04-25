classdef Stereoacuity_MethodOfConstantStimuli < ArumeExperimentDesigns.EyeTracking
    % DEMO experiment for Arume
    %
    %   1. Copy paste the folder @Demo within +ArumeExperimentDesigns.
    %   2. Rename the folder with the name of the new experiment but keep that @ at the begining!
    %   3. Rename also the file inside to match the name of the folder (without the @ this time).
    %   4. Then change the name of the class inside the folder.
    %
    properties
        stimTextureLeft = [];
        stimTextureRight = [];
        targetColor = [150 150 150];
    end
    
    % ---------------------------------------------------------------------
    % Experiment design methods
    % ---------------------------------------------------------------------
    methods ( Access = protected )
        function dlg = GetOptionsDialog( this, importing )
            dlg = GetOptionsDialog@ArumeExperimentDesigns.EyeTracking(this, importing);
            
            %% ADD new options
            dlg.InitDisparity = { 5 '* (arcmins)' [0 100] };
            dlg.InitStepSize = { 15 '* (arcmins)' [0 100] };
            dlg.Number_of_Dots = { 3000 '* (deg/s)' [10 10000] };
            dlg.Size_of_Dots = { 4 '* (pix)' [1 100] };
            dlg.visibleWindow_cm = {16 '* (cm)' [1 100] };
            dlg.FixationSpotSize = { 0.4 '* (diameter_in_deg)' [0 5] };
            dlg.TimeStimOn = { 0.5 '* (sec)' [0 60] };
            
            dlg.NumberOfRepetitions = {10 '* (N)' [1 200] };
            dlg.BackgroundBrightness = 0;
            
            %% CHANGE DEFAULTS values for existing options
            
            dlg.UseEyeTracker = 0;
            dlg.Debug.DisplayVariableSelection = 'TrialNumber TrialResult RotateDots DisparityArcMin GuessedCorrectly'; % which variables to display every trial in the command line separated by spaces
            
            dlg.DisplayOptions.ScreenWidth = { 59.5 '* (cm)' [1 3000] };
            dlg.DisplayOptions.ScreenHeight = { 34 '* (cm)' [1 3000] };
            dlg.DisplayOptions.ScreenDistance = { 54 '* (cm)' [1 3000] };
            dlg.DisplayOptions.StereoMode = { 4 '* (mode)' [0 9] };
            dlg.DisplayOptions.SelectedScreen = { 2 '* (screen)' [0 5] };
            
            dlg.HitKeyBeforeTrial = 1;
            dlg.TrialDuration = 90;
            dlg.TrialsBeforeBreak = 1200;
            dlg.TrialAbortAction = 'Repeat';
        end
        
        function trialTable = SetUpTrialTable(this)
            
            %-- condition variables ---------------------------------------
            i= 0;
            
            i = i+1;
            conditionVars(i).name   = 'Disparities';
            conditionVars(i).values = [0.1:0.05:0.8];
            
            i = i+1;
            conditionVars(i).name   = 'RotateDots';
            conditionVars(i).values = [0 5 10 45]; %5 10 45];
            
            i = i+1;
            conditionVars(i).name   = 'SignDisparity';
            conditionVars(i).values = [-1 1];
            
            trialTableOptions = this.GetDefaultTrialTableOptions();
            trialTableOptions.trialSequence = 'Random';
            trialTableOptions.trialAbortAction = 'Repeat'; % Repeat, Delay, Drop
            trialTableOptions.trialsPerSession = 1000;
            trialTableOptions.numberOfTimesRepeatBlockSequence = this.ExperimentOptions.NumberOfRepetitions;
            trialTable = this.GetTrialTableFromConditions(conditionVars, trialTableOptions);
        end
        
        
        %         function [trialResult, thisTrialData] = runPreTrial( this, thisTrialData )
        %             Enum = ArumeCore.ExperimentDesign.getEnum();
        %             trialResult = Enum.trialResult.CORRECT;
        %
        %             % Calculate the disparity, depending on whether or not the staircase exists
        %
        %             if isempty(this.Session.currentRun.pastTrialTable) || isempty(find(this.Session.currentRun.pastTrialTable.SignDisparity == thisTrialData.SignDisparity & this.Session.currentRun.pastTrialTable.RotateDots == thisTrialData.RotateDots)) % if this is the first trial of the whole experiment or if this staircase has never occured before
        %                  thisTrialData.DisparityArcMinLogAbs = log(this.ExperimentOptions.InitDisparity); % first disparity of this staircase will be the initial disparity
        %
        %             else
        %                 thisTrialsStaircaseTrials = find(this.Session.currentRun.pastTrialTable.SignDisparity == thisTrialData.SignDisparity & this.Session.currentRun.pastTrialTable.RotateDots == thisTrialData.RotateDots);
        %                 numReversals = sum(this.Session.currentRun.pastTrialTable.IsReversal(thisTrialsStaircaseTrials));
        %
        %                 % What the disparity will be on this trial, given the response on the last trial
        %                 lastAbsoluteTrialDisparity = this.Session.currentRun.pastTrialTable.DisparityArcMinLogAbs(thisTrialsStaircaseTrials(end)); % this should already be in log units, so don't need to change anything here
        %                 lastTrialGuessedCorrectly = this.Session.currentRun.pastTrialTable.GuessedCorrectly(thisTrialsStaircaseTrials(end));
        %                 absoluteDisparityArcMin = lastAbsoluteTrialDisparity - (log(this.ExperimentOptions.InitStepSize)) / (numReversals+1) * (lastTrialGuessedCorrectly - 0.8); % from Faes 2007, https://link.springer.com/article/10.3758/BF03193747
        %                 thisTrialData.DisparityArcMinLogAbs = absoluteDisparityArcMin;
        %
        % %                 % probably don't need this now that we're doing log?
        % %                 if exp(thisTrialData.DisparityArcMinLog) > 0 & thisTrialData.SignDisparity == -1 % if you went below/above zero when you weren't supposed to
        % %                     thisTrialData.DisparityArcMinLog = 0.001 *  thisTrialData.SignDisparity;
        % %                 elseif exp(thisTrialData.DisparityArcMinLog) < 0 & thisTrialData.SignDisparity == 1 % if you went below/above zero when you weren't supposed to
        % %                     thisTrialData.DisparityArcMinLog = 0.001 *  thisTrialData.SignDisparity;
        % %                 end
        %             end
        %
        %             thisTrialData.DisparityArcMinLog =  thisTrialData.DisparityArcMinLogAbs * thisTrialData.SignDisparity;
        %             thisTrialData.DisparityArcMin = exp(thisTrialData.DisparityArcMinLogAbs) * thisTrialData.SignDisparity;
        %
        %         end
        
        
        function [trialResult, thisTrialData] = runTrial( this, thisTrialData )
            
            try
                
                Enum = ArumeCore.ExperimentDesign.getEnum();
                graph = this.Graph;
                trialResult = Enum.trialResult.CORRECT;
                
                Screen('FillRect', graph.window, 0); % not sure if needed
                
                % Screen width and height of one of the two eye displays in pixels
                screenWidth = this.Graph.wRect(3);
                screenHeight = this.Graph.wRect(4);
                
                % Settings
                moniterWidth_cm =  this.ExperimentOptions.DisplayOptions.ScreenWidth;
                viewingDist = this.ExperimentOptions.DisplayOptions.ScreenDistance;
                moniterWidth_deg = (atan2d(moniterWidth_cm/2, viewingDist)) * 2;
                pixPerDeg = (screenWidth*2) / moniterWidth_deg;
                
                % Stimulus settings:
                numDots = this.ExperimentOptions.Number_of_Dots;
                dots = zeros(3, numDots);
                
                % How big should the window (entire dots stimulus) be in pix?
                visibleWindow_cm = this.ExperimentOptions.visibleWindow_cm; % in cm, this is how much of the screen you can see w one eye at a viewingDist of 20 (from haploscope calcs!)
                visibleWindow_pix = ((screenWidth*2) / moniterWidth_cm) * visibleWindow_cm;
                xmax = visibleWindow_pix / 2;
                ymax = xmax;
                
                % Disparity settings:
                thisTrialData.DisparityArcMin = thisTrialData.Disparities * thisTrialData.SignDisparity;
                disparity_deg = thisTrialData.DisparityArcMin/60;
                shiftNeeded_cm = viewingDist * tand(disparity_deg);
                shiftNeeded_pix = ((screenWidth*2) / moniterWidth_cm) * shiftNeeded_cm;
                %shiftNeeded_pix = pixPerDeg * shiftNeeded_deg;
                dots(1, :) = 2*(xmax)*rand(1, numDots) - xmax; % SR x coords
                dots(2, :) = 2*(ymax)*rand(1, numDots) - ymax; % SR y coords
                
                % Get fixation spot size in pix
                fixSizePix = pixPerDeg * this.ExperimentOptions.FixationSpotSize;
                
                % Make the window (entire dot stimulus) circular :D
                distFromCenter = sqrt((dots(1,:)).^2 + (dots(2,:)).^2);
                while isempty(distFromCenter(distFromCenter>ymax | distFromCenter<fixSizePix)) == 0 % while there are dots that are outside of the desired circle
                    idxs=find(distFromCenter>ymax | distFromCenter<fixSizePix);
                    dots(1, idxs) = 2*(xmax)*rand(1, length(idxs)) - xmax; % resample those dots
                    dots(2, idxs) = 2*(ymax)*rand(1, length(idxs)) - ymax;
                    distFromCenter = sqrt((dots(1,:)).^2 + (dots(2,:)).^2);
                end
                dots(3, :) = (ones(size(dots,2),1)')*shiftNeeded_pix; % how much the dots will shift by in pixels
                
                %                 % Stim Prep for shifting only the center dots of the stimulus (not the
                %                 % whole thing). The inside center dots shifting is a square, not circle.
                %                 vec_x = dots(1, :);
                %                 vec_y = dots(2, :);
                %                 vec_x(vec_x < -xmax/2) = 0;
                %                 vec_x(vec_x > xmax/2) = 0;
                %                 vec_y(vec_y < -ymax/2) = 0;
                %                 vec_y(vec_y > ymax/2) = 0;
                %                 idx_x = find(vec_x==0);
                %                 idx_y = find(vec_y==0);
                %                 dots(3,idx_x) = 0;
                %                 dots(3,idx_y) = 0;
                %
                % Right and left shifted dots
                leftStimDots = dots(1:2, :) + [dots(3, :)/2; zeros(1, numDots)]; % zeros here bc no shift in vertical dots
                rightStimDots = dots(1:2, :) - [dots(3, :)/2; zeros(1, numDots)];
                
                % Rotating the dots if needed
                leftDistFromCenter = sqrt((leftStimDots(1,:)).^2 + (leftStimDots(2,:)).^2); %where leftStimDots(1,:) is the x coord and leftStimDots(2,:) is the y coord
                leftThetaDeg = atan2d(leftStimDots(2,:),leftStimDots(1,:));
                leftPolarPtX = cosd(leftThetaDeg + thisTrialData.RotateDots) .* leftDistFromCenter;
                leftPolarPtY = sind(leftThetaDeg + thisTrialData.RotateDots) .* leftDistFromCenter;
                rightDistFromCenter = sqrt((rightStimDots(1,:)).^2 + (rightStimDots(2,:)).^2); %where leftStimDots(1,:) is the x coord and leftStimDots(2,:) is the y coord
                rightThetaDeg = atan2d(rightStimDots(2,:),rightStimDots(1,:));
                rightPolarPtX = cosd(rightThetaDeg + thisTrialData.RotateDots) .* rightDistFromCenter;
                rightPolarPtY = sind(rightThetaDeg + thisTrialData.RotateDots) .* rightDistFromCenter;
                % rotated dots
                leftStimDots = [leftPolarPtX;leftPolarPtY];
                rightStimDots = [rightPolarPtX;rightPolarPtY];
                
                % What the response should be
                if thisTrialData.DisparityArcMin > 0
                    thisTrialData.CorrectResponse = 'F';
                elseif thisTrialData.DisparityArcMin < 0
                    thisTrialData.CorrectResponse = 'B';
                    %                 elseif thisTrialData.DisparityArcMin == 0
                    %                     thisTrialData.DisparityArcMin
                    %                     disp('Crashed here')
                    %                     thisTrialData.DisparityArcMin
                end
                
                % For the while loop trial start
                trialDuration = this.ExperimentOptions.TrialDuration;
                lastFlipTime                        = Screen('Flip', graph.window);
                secondsRemaining                    = trialDuration;
                thisTrialData.TimeStartLoop         = lastFlipTime;
                
                response = []; %initialize this
                
                while secondsRemaining > 0
                    
                    secondsElapsed      = GetSecs - thisTrialData.TimeStartLoop;
                    secondsRemaining    = trialDuration - secondsElapsed;
                    
                    
                    % -----------------------------------------------------------------
                    % --- Drawing of stimulus -----------------------------------------
                    % -----------------------------------------------------------------
                    
                    
                    if ( secondsElapsed <= this.ExperimentOptions.TimeStimOn ) % then show dots + fixation dot
                        % Select left-eye image buffer for drawing:
                        Screen('SelectStereoDrawBuffer', this.Graph.window, 0);
                        
                        % Draw left stim:
                        Screen('DrawDots', this.Graph.window, leftStimDots, this.ExperimentOptions.Size_of_Dots, [], this.Graph.wRect(3:4)/2, 1); % the 1 at the end means dot type where 1 2 or 3 is circular
                        Screen('DrawDots', this.Graph.window, [0;0], fixSizePix, this.targetColor, this.Graph.wRect(3:4)/2, 1); % fixation spot
                        Screen('FrameRect', this.Graph.window, [1 0 0], [], 5);
                        
                        % Select right-eye image buffer for drawing:
                        Screen('SelectStereoDrawBuffer', this.Graph.window, 1);
                        
                        % Draw right stim:
                        Screen('DrawDots', this.Graph.window, rightStimDots, this.ExperimentOptions.Size_of_Dots, [], this.Graph.wRect(3:4)/2, 1);
                        Screen('DrawDots', this.Graph.window, [0;0], fixSizePix, this.targetColor, this.Graph.wRect(3:4)/2, 1); % fixation spot
                        Screen('FrameRect', this.Graph.window, [0 1 0], [], 5);
                        
                    end
                    
                    if ( secondsElapsed > this.ExperimentOptions.TimeStimOn ) % then show only fixation dot
                        % Select left-eye image buffer for drawing:
                        Screen('SelectStereoDrawBuffer', this.Graph.window, 0);
                        
                        % Draw left stim:
                        Screen('DrawDots', this.Graph.window, [0;0], fixSizePix, this.targetColor, this.Graph.wRect(3:4)/2, 1); % fixation spot
                        Screen('FrameRect', this.Graph.window, [1 0 0], [], 5);
                        
                        % Select right-eye image buffer for drawing:
                        Screen('SelectStereoDrawBuffer', this.Graph.window, 1);
                        
                        % Draw right stim:
                        Screen('DrawDots', this.Graph.window, [0;0], fixSizePix, this.targetColor, this.Graph.wRect(3:4)/2, 1); % fixation spot
                        Screen('FrameRect', this.Graph.window, [0 1 0], [], 5);
                        
                        
                    end
                    
                    
                    % -----------------------------------------------------------------
                    % --- END Drawing of stimulus -------------------------------------
                    % -----------------------------------------------------------------
                    
                    % -----------------------------------------------------------------
                    % -- Flip buffers to refresh screen -------------------------------
                    % -----------------------------------------------------------------
                    this.Graph.Flip(this, thisTrialData, secondsRemaining);
                    % -----------------------------------------------------------------
                    
                    
                    % -----------------------------------------------------------------
                    % --- Collecting responses  ---------------------------------------
                    % -----------------------------------------------------------------
                    
                    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
                    if ( keyIsDown )
                        keys = find(keyCode);
                        for i=1:length(keys)
                            KbName(keys(i));
                            switch(KbName(keys(i)))
                                case 'RightArrow'
                                    response = 'F';
                                case 'LeftArrow'
                                    response = 'B';
                            end
                        end
                        if ( ~isempty(response) ) % if there is a response, break this trial and start the next
                            thisTrialData.Response = response;
                            thisTrialData.ResponseTime = GetSecs;
                            break;
                        end
                    end
                end
                
                if ( isempty(response) )
                    thisTrialData.Response = 'NoResponse';
                    thisTrialData.ResponseTime = GetSecs;
                    trialResult = Enum.trialResult.ABORT;
                else
                    trialResult = Enum.trialResult.CORRECT;
                end
                
                
            catch ex
                rethrow(ex)
            end
            
        end
        
        function [trialResult, thisTrialData] = runPostTrial( this, thisTrialData )
            % Record if the subject guessed correctly or not
            if thisTrialData.Response == thisTrialData.CorrectResponse
                thisTrialData.GuessedCorrectly = 1;
            elseif thisTrialData.Response ~= thisTrialData.CorrectResponse
                thisTrialData.GuessedCorrectly = 0;
            end
            
            % Record if the trial was a reversal
            if isempty(this.Session.currentRun.pastTrialTable) | isempty(find(this.Session.currentRun.pastTrialTable.DisparityArcMin == thisTrialData.DisparityArcMin & this.Session.currentRun.pastTrialTable.RotateDots == thisTrialData.RotateDots)) % if this is the first trial of the whole experiment or if this staircase has never occured before
                thisTrialData.IsReversal = 0;
            elseif thisTrialData.GuessedCorrectly == this.Session.currentRun.pastTrialTable.GuessedCorrectly(find(this.Session.currentRun.pastTrialTable.DisparityArcMin == thisTrialData.DisparityArcMin & this.Session.currentRun.pastTrialTable.RotateDots == thisTrialData.RotateDots,1,'last'))
                thisTrialData.IsReversal = 0;
            elseif thisTrialData.GuessedCorrectly ~= this.Session.currentRun.pastTrialTable.GuessedCorrectly(find(this.Session.currentRun.pastTrialTable.DisparityArcMin == thisTrialData.DisparityArcMin & this.Session.currentRun.pastTrialTable.RotateDots == thisTrialData.RotateDots,1,'last'))
                thisTrialData.IsReversal = 1;
            end
            
            % Move this forward
            trialResult = thisTrialData.TrialResult;
            
        end
        
        
    end
    
    methods
        
        function [out] = Plot_Psychometric_Curve(this)
            %%
            t = this.Session.trialDataTable;
            
            
            % Plotting the psychometric function
            RotateDotsCond = unique(t.RotateDots); %[0,5,10,45];
            SignDispCond = [1 -1];
            whichone = 1; figure(1);
            
            % lets start with just one condition
            for asign = 1:length(SignDispCond)
                for arotation = 1:length(RotateDotsCond)
                    idxs = find(t.SignDisparity == SignDispCond(asign) & t.RotateDots == RotateDotsCond(arotation))
                    temp=array2table([t.DisparityArcMin(idxs) t.GuessedCorrectly(idxs)],'VariableNames',{'DisparityArcMin','GuessedCorrectly'});
                    temp_sorted = sortrows(temp);
                    
                    % Define the ranges for alpha and beta that you want to search over
                    aRange = linspace(-2,2,height(temp)); %"threshold" parameter range, alpha
                    bRange = linspace(-10,30,height(temp)); %"slope" parameter range, beta
                    LLE = zeros(length(bRange),length(aRange));
                    loglikelihood_trials = [];
                    
                    % For all combinations of alpha and beta, get the log likelihoods
                    % for each trial describing how likely it is for that data point to
                    % exist based on the tested alpha + beta
                    for bi = 1:length(bRange)
                        for ai = 1:length(aRange)
                            for atrial = 1:height(temp)
                                switch (true)
                                    case SignDispCond(asign) == 1
                                        if temp.GuessedCorrectly(atrial) == 1
                                            loglikelihood_trials(atrial) = log( 0.5./(1+exp(-bRange(bi).*(temp.DisparityArcMin(atrial)-aRange(ai))))+0.5); % logistic equation: 1./(1 + exp(-b.*(x-a)))
                                            
                                        elseif temp.GuessedCorrectly(atrial) == 0
                                            loglikelihood_trials(atrial) = log( 1- (0.5./(1+exp(-bRange(bi).*(temp.DisparityArcMin(atrial)-aRange(ai)))) +0.5) );
                                            
                                        end
                                    case SignDispCond(asign) == -1
                                        if temp.GuessedCorrectly(atrial) == 1
                                            loglikelihood_trials(atrial) = log( 0.5./(1+exp(bRange(bi).*(temp.DisparityArcMin(atrial)-aRange(ai))))+0.5); % logistic equation: 1./(1 + exp(-b.*(x-a)))
                                            
                                        elseif temp.GuessedCorrectly(atrial) == 0
                                            loglikelihood_trials(atrial) = log( 1- (0.5./(1+exp(bRange(bi).*(temp.DisparityArcMin(atrial)-aRange(ai)))) +0.5) );
                                            
                                        end
                                end
                            end
                            % Sum the log likelihoods for all the trials and put it
                            % into a matrix for an alpha/beta combination
                            LLE(bi,ai) = sum(loglikelihood_trials);
                            
                        end
                        %plot(LLE(bi,:)); pause;
                    end
                    
                    % Get the maximum likelihood of the alpha and beta parameters
                    [themax,theidx]=max(LLE(:));
                    [maybeX,maybeY] = meshgrid(1:height(temp),1:height(temp));
                    if maybeX(theidx) == 1 | maybeX(theidx) == 100 | maybeY(theidx) == 1 | maybeY(theidx) == 100
                        disp('search range isnt big enough!')
                        break
                    end
                    the_a_parameter = aRange(maybeX(theidx));
                    the_b_parameter = bRange(maybeY(theidx));
                    
                    % What is the 80% threshold from our staircase
                    p=0.8; %from arume staircase
                    what_is_the_threshold = (log(1-p / p-0.5)) ./ -the_b_parameter + the_a_parameter;
                    
                    % Preparing visualization
                    temp_sorted.meanedResp=zeros(height(temp_sorted),1);
                    [C,IA] = unique(temp_sorted.DisparityArcMin)
                    for i = 1:length(IA)
                        starting = IA(i);
                        if i == length(IA) % if its the last iteration
                            temp_sorted.meanedResp(starting:end) = mean(temp_sorted.GuessedCorrectly(starting:end));
                        else
                            ending = IA(i+1)-1;
                            temp_sorted.meanedResp(starting:ending) = mean(temp_sorted.GuessedCorrectly(starting:ending));
                        end
                    end
                    
                    % Visualize!
                    subplot(2,4,whichone)
                    if SignDispCond(asign) == 1
                        plot(temp_sorted.DisparityArcMin,temp_sorted.meanedResp,'o'); hold on
                        x=0:0.01:1;
                        plot(x, 0.5./(1 + exp(-the_b_parameter.*(x-the_a_parameter)))+0.5,'linewidth',2);
                    elseif SignDispCond(asign) == -1
                        plot(temp_sorted.DisparityArcMin,temp_sorted.meanedResp,'o'); hold on
                        x=-1:0.01:0;
                        plot(x, 0.5./(1 + exp(the_b_parameter.*(x-the_a_parameter)))+0.5,'linewidth',2);
                    end
                    ylim([0 1])
                    xlabel('Disparity (arcmin)')
                    ylabel('Proportion Correct')
                    title(sprintf('Rotation: %s',string(RotateDotsCond(arotation))))
                    text(min(xlim)+0.05, min(ylim)+0.13, sprintf('Threshold param: %.2f', what_is_the_threshold), 'Horiz','left', 'Vert','bottom')
                    text(min(xlim)+0.05, min(ylim)+0.08, sprintf('Alpha param: %.2f', the_a_parameter), 'Horiz','left', 'Vert','bottom')
                    text(min(xlim)+0.05, min(ylim)+0.03, sprintf('Beta param: %.2f', the_b_parameter), 'Horiz','left', 'Vert','bottom')
                    
                    whichone = whichone + 1;
                    
                end
            end
            
            
            
        end
    end
    
    
    
end
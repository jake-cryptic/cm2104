classdef basic_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        TabGroup                        matlab.ui.container.TabGroup
        PlotControlsTab                 matlab.ui.container.Tab
        EstimatevalueusingButtonGroup   matlab.ui.container.ButtonGroup
        SquaresButton                   matlab.ui.control.RadioButton
        NeedlesButton                   matlab.ui.control.RadioButton
        BestagonsButton                 matlab.ui.control.RadioButton
        NumberofsquaresSpinnerLabel     matlab.ui.control.Label
        NumberofitemSpinner             matlab.ui.control.Spinner
        NumberoffloorplanksSliderLabel  matlab.ui.control.Label
        NumberoffloorplanksSlider       matlab.ui.control.Slider
        EstimatevalueofButtonGroup      matlab.ui.container.ButtonGroup
        piButton                        matlab.ui.control.RadioButton
        roottwoButton                   matlab.ui.control.RadioButton
        goldenratioButton               matlab.ui.control.RadioButton
        EstimateButton                  matlab.ui.control.Button
        LengthofsquaresidesSliderLabel  matlab.ui.control.Label
        LengthofitemsidesSlider         matlab.ui.control.Slider
        WarningSquarelengthPlankdistanceLabel  matlab.ui.control.Label
        NHorizontalTilesSliderLabel     matlab.ui.control.Label
        NHorizontalTilesSlider          matlab.ui.control.Slider
        SelectTaskButtonGroup           matlab.ui.container.ButtonGroup
        ButtonTask1                     matlab.ui.control.ToggleButton
        ButtonTask2                     matlab.ui.control.ToggleButton
        ButtonTask3                     matlab.ui.control.ToggleButton
        ButtonTask5                     matlab.ui.control.ToggleButton
        SelectedNeedleControlsButtonGroup  matlab.ui.container.ButtonGroup
        DonothingButton                 matlab.ui.control.ToggleButton
        HighlightsimilaranglesButton    matlab.ui.control.ToggleButton
        HighlightclosestButton          matlab.ui.control.ToggleButton
        nSpinnerLabel                   matlab.ui.control.Label
        nSpinner                        matlab.ui.control.Spinner
        MinimumlengthofneedlesLabel     matlab.ui.control.Label
        MinLengthOfNeedlesSlider        matlab.ui.control.Slider
        ClearButton                     matlab.ui.control.Button
        UIControlsTab                   matlab.ui.container.Tab
        TabGroup2                       matlab.ui.container.TabGroup
        OutputTab                       matlab.ui.container.Tab
        FontSizeSliderLabel             matlab.ui.control.Label
        FontSizeSlider                  matlab.ui.control.Slider
        ModifyFontColourButton          matlab.ui.control.Button
        CurrentFontColorLamp            matlab.ui.control.Lamp
        SwitchLabel                     matlab.ui.control.Label
        AutoRerunSimulation             matlab.ui.control.Switch
        FigureTab                       matlab.ui.container.Tab
        ModifyShapeColourNonIntersectButton  matlab.ui.control.Button
        CurrentShapeColourNonIntersect  matlab.ui.control.Lamp
        ModifyShapeColourIntersectButton  matlab.ui.control.Button
        CurrentShapeColourIntersect     matlab.ui.control.Lamp
        ModifyGridLineColourButton      matlab.ui.control.Button
        CurrentGridLineColour           matlab.ui.control.Lamp
        GridLineThicknessSpinnerLabel   matlab.ui.control.Label
        GridLineThicknessSpinner        matlab.ui.control.Spinner
        ModifyShapeColourSelectedButton  matlab.ui.control.Button
        CurrentShapeColourSelected      matlab.ui.control.Lamp
        ModifyShapeColourSimilarButton  matlab.ui.control.Button
        CurrentShapeColourSimilar       matlab.ui.control.Lamp
        changesReplotWarningLabel       matlab.ui.control.Label
        CurrentFigureBackgroundColour   matlab.ui.control.Lamp
        ModifyFigureBackgroundColourButton  matlab.ui.control.Button
        NeedleLineThicknessSpinnerLabel  matlab.ui.control.Label
        NeedleLineThicknessSpinner      matlab.ui.control.Spinner
        FilesTab                        matlab.ui.container.Tab
        ImportNewNeedlesButton          matlab.ui.control.Button
        ExportCurrentNeedlesButton      matlab.ui.control.Button
        OverwritecurrentplotonimportButtonGroup  matlab.ui.container.ButtonGroup
        YesButton                       matlab.ui.control.ToggleButton
        NoButton                        matlab.ui.control.ToggleButton
        SaveCurrentPlotLabel            matlab.ui.control.Label
        LoadExportedPlotLabel           matlab.ui.control.Label
        LoadExportedDescLabel           matlab.ui.control.Label
        LoadExportedDescLabel_2         matlab.ui.control.Label
        OutEstimateLabel                matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
		calc    =   1                   % What are we calculating? 1 = pi, 2 = sqrt(2)
        S	    =	1					% Scale factor
        N	    =	750					% Number of shapes
		NoVP	=	5				    % Number of planks
        NoHP    =   5                   % Number of horizontal planks
		DV							    % Distance between vertical planks
		DH							    % Distance between horizontal planks
		SL							    % Length of shape
		RS								% Scale factor in matrix form
		RSL								% Random lengths of shapes
		RUB								% Upper bound for random lengths
		RLB								% Lower bount for random lengths
        Similar =   3                   % Number of similar needles
        
        % Customisation variables
        uiGridlineWidth = 2
		uiNeedleLineWidth = 1
        uiGridlineColor = [0 0 0]
        uiSelectedPolyColor = [0 0 1]
        uiIntersectPolyColor = [1 0 0]
        uiNonIntersectPolyColor = [0 1 0]
        uiSimilarPolyColor = [0.72 0.27 1.0]
        
		% Logical masks for changing plot line colours
		maskIntersecting
		maskSimilar
		
        % Task state of UI
        currentTask = 1
        highlightTask = 0
		
		% Import / Export settings
		overwriteOnImport = true
		
		% Patch & plot objects
		pat
        plt
        
        % Grid line objects for ui customisation
        gridlinesH
        gridlinesV
        
        % State information for the needle interactivity
        lastClickedLine
        lastClickedLineColor = [0 0 0]
		
		% State variables
		sq_angles
		xc
		yc
		xcr
		ycr
        
		n_angles            % Needle rotation angles list
		nxc                 % Needle x-coord list
		nyc                 % Needle y-coord list
		nxcr                % Needle x-coord rotated list
		nycr                % Needle y-coord rotated list
        nmd                 % Needle gradient list
    end
    
    methods (Access = private)
        
		function beginEstimation(app)
            if app.currentTask == 1 || app.currentTask == 2
			    updateSquarePlot(app);
			else
                app.lastClickedLine = [];
                app.lastClickedLineColor = [0 0 0];
                
                updateNeedlePlot(app);
            end
        end
		
		function updatePlankCount(app, plankCount)
			app.NoVP = plankCount;
			app.DV = app.S / app.NoVP;
            makeWarningForLgtD(app);
			
			beginEstimation(app);
        end
		
        function updateHorizontalPlankCount(app, plankCount)
			app.NoVP = plankCount;
			app.DH = app.S / app.NoVP;
            makeWarningForLgtD(app);
            
			beginEstimation(app);
        end
        
        function makeWarningForLgtD(app)
            if app.SL > app.DV
                set(app.WarningSquarelengthPlankdistanceLabel, 'Visible', true);
            else
                set(app.WarningSquarelengthPlankdistanceLabel, 'Visible', false);
            end
        end
        
        function updateItemCount(app, itemCount)
			app.N = itemCount;
			beginEstimation(app);
		end
        
        function updateItemLength(app, itemLength)
			if app.currentTask == 5
				app.RUB = itemLength;
			else
				makeWarningForLgtD(app);
			end
			
			app.SL = itemLength;
			beginEstimation(app);
        end
        
        function updateNeedleRanomisation(app)
			app.n_angles = rand(1, app.N) * 360;
			
			% Calculate starting coordinates
			app.nxc = rand(1, app.N);
			app.nyc = rand(1, app.N);
			
			% Calculate rotated end coordinates
			app.nxcr = app.nxc + app.SL * cosd(app.n_angles);
			app.nycr = app.nyc + app.SL * sind(app.n_angles);
        end
        
		function updateRandomLengthNeedleRanomisation(app)
			app.RS = ones(1, app.N);
			app.n_angles = rand(1, app.N) * 360;
			
			% Random lengths
			app.RSL = app.RLB + (app.RUB - app.RLB) .* rand(1, app.N);
			
			% Calculate starting coordinates
			app.nxc = app.RSL + rand(1, app.N) .* (app.RS - 2 * app.RSL);
			app.nyc = app.RSL + rand(1, app.N) .* (app.RS - 2 * app.RSL);
			
			% Calculate rotated end coordinates
			app.nxcr = app.nxc + app.RSL .* cosd(app.n_angles);
			app.nycr = app.nyc + app.RSL .* sind(app.n_angles);
        end
        
        function workOutNeedleGradients(app)
            app.nmd = 1:app.N;
            for i = 1:app.N
                app.nmd(i) = (app.nyc(i) - app.nycr(i)) / (app.nxc(i) - app.nxcr(i));
            end
        end
		
		function updateNeedlePlot(app)
			UIDoClearAxes(app);
			
			if app.currentTask == 3
				updateNeedleRanomisation(app);
				calculateNeedlePi(app);
			else
				updateRandomLengthNeedleRanomisation(app);
				calculateRandomLengthNeedlePi(app);
			end
            
			workOutNeedleGradients(app);
            
            plotNeedles(app);
		end
		
		function plotNeedles(app)
			% Find those that intersect either a y-line or x-line
			if app.currentTask == 3
				intersecting = (floor(app.nyc / app.DH) ~= floor(app.nycr / app.DH)) | (floor(app.nxc / app.DV) ~= floor(app.nxcr / app.DV));
			else
				intersecting = (floor(app.nxc / app.DV) ~= floor(app.nxcr / app.DV));
			end
			
            % Plot needles
            app.plt = plot(app.UIAxes, [app.nxc; app.nxcr], [app.nyc; app.nycr], 'LineWidth', app.uiNeedleLineWidth, 'Color', app.uiIntersectPolyColor);
            
            % Change color of those who do not intersect
            set(app.plt(~intersecting), 'Color', app.uiNonIntersectPolyColor);
            
            % Assign callbacks for needle interaction
			set(app.plt, 'ButtonDownFcn', @app.LineSelected);
			
			% Set this so we can change colours without re-drawing plot
			app.maskIntersecting = intersecting;
			
            % Plot gridlines
			updatePlotFloor(app);
		end
		
		function updateSquareRanomisation(app)
			app.sq_angles = rand(1, app.N) * 90;
			app.xc = rand(1, app.N);
			app.yc = rand(1, app.N);
		end
		
		function updateSquarePlot(app)
			UIDoClearAxes(app);
			updateSquareRanomisation(app);
			updatePlotFloor(app);
			
            % Calculate rotated square angles
            rad = app.SL / 2;
			app.xcr = [...
				rad * cosd(app.sq_angles) + rad * sind(app.sq_angles) + app.xc;...
				rad * cosd(app.sq_angles) - rad * sind(app.sq_angles) + app.xc;...
				-rad * cosd(app.sq_angles) - rad * sind(app.sq_angles) + app.xc;...
				-rad * cosd(app.sq_angles) + rad * sind(app.sq_angles) + app.xc;...
			];
			app.ycr = [...
				-rad * sind(app.sq_angles) + rad * cosd(app.sq_angles) + app.yc;...
				-rad * sind(app.sq_angles) - rad * cosd(app.sq_angles) + app.yc;...
				rad * sind(app.sq_angles) - rad * cosd(app.sq_angles) + app.yc;...
				rad * sind(app.sq_angles) + rad * cosd(app.sq_angles) + app.yc;...
			];
			
            % Figure out what we are estimating
            if app.calc == 1
			    calculateSquarePi(app);
            else
                calculateSquareSqrtTwo(app);
            end
            
			plotSquares(app);
		end
		
		function plotSquares(app)
            % Find squares that intersect
            intersecting = floor(app.xcr(1, :)/app.DV) ~= floor(app.xcr(2, :)/app.DV) | floor(app.xcr(2, :)/app.DV) ~= floor(app.xcr(3, :)/app.DV) |...
                floor(app.xcr(3, :)/app.DV) ~= floor(app.xcr(4, :)/app.DV) | floor(app.xcr(4, :)/app.DV) ~= floor(app.xcr(1, :)/app.DV);
			
			% Set this so we can change colours without re-drawing plot
			app.maskIntersecting = intersecting;
			
            % Plot the squares
			app.pat = patch(app.UIAxes, app.xcr(:,intersecting), app.ycr(:,intersecting), 'w', 'EdgeColor', app.uiIntersectPolyColor);
            app.pat = [app.pat, patch(app.UIAxes, app.xcr(:,~intersecting), app.ycr(:,~intersecting), 'w', 'EdgeColor', app.uiNonIntersectPolyColor)];
		end
		
		function calculateNeedlePi(app)
			% Find intersections on both horizontal and verticle lines
			n = 0;
			n = n + sum((floor(app.nyc / app.DH) ~= floor(app.nycr / app.DH)) | floor(app.nxc / app.DV) ~= floor(app.nxcr / app.DV));
		
			p = (n/app.N);
			a = app.DH;
			b = app.DV;
			
			% Use equation from research paper to estimate pi
			pi_estimate = ((2 * app.SL * (a + b)) - app.SL^2) / (p * a * b);
			UIUpdateOutEstimate(app, ['Needle Pi Estimate: ' num2str(pi_estimate)]);
		end
		
		function calculateRandomLengthNeedlePi(app)
			% Calculate the mean needle length
			L = mean(app.RSL);
			
			% Calculate number of intersections
			n = 0;
			n = n + sum(floor(app.nxc / app.DV) ~= floor(app.nxcr / app.DV));
			
			% Use original buffons needle equation to estimate pi
			%pi_estimate = (2 * app.N * L) / n * app.DV;
			pi_estimate = (app.N * 2) / n;
			UIUpdateOutEstimate(app, ['Random Length Needle Pi Estimate: ' num2str(pi_estimate)]);
		end
		
		function calculateSquarePi(app)
            % Count total number of intersections
			n = 0;
			n = n + sum(floor(app.xcr(1, :)/app.DV) ~= floor(app.xcr(2, :)/app.DV)) + ...
					sum(floor(app.xcr(2, :)/app.DV) ~= floor(app.xcr(3, :)/app.DV)) + ...
					sum(floor(app.xcr(3, :)/app.DV) ~= floor(app.xcr(4, :)/app.DV)) + ...
					sum(floor(app.xcr(4, :)/app.DV) ~= floor(app.xcr(1, :)/app.DV));
            
            %sqi = [floor(app.xcr(1, :)/app.DV) ~= floor(app.xcr(2, :)/app.DV); floor(app.xcr(2, :)/app.DV) ~= floor(app.xcr(3, :)/app.DV); floor(app.xcr(3, :)/app.DV) ~= floor(app.xcr(4, :)/app.DV); floor(app.xcr(4, :)/app.DV) ~= floor(app.xcr(1, :)/app.DV)]'
            
			t = 2 * (app.N * 4) * app.SL;
			
			pi_estimate = t / (n * app.DV);
			UIUpdateOutEstimate(app, ['Pi Estimate: ' num2str(pi_estimate)]);
        end
		
		function calculateSquareSqrtTwo(app)
            % Calculate total intersections
            total_intersected = sum(floor(app.xcr(1, :)/app.DV) ~= floor(app.xcr(2, :)/app.DV) | floor(app.xcr(2, :)/app.DV) ~= floor(app.xcr(3, :)/app.DV) |...
                floor(app.xcr(3, :)/app.DV) ~= floor(app.xcr(4, :)/app.DV) | floor(app.xcr(4, :)/app.DV) ~= floor(app.xcr(1, :)/app.DV));
            
            % Calculate consequtive side intersections
            total_consequtive = 0;
            total_consequtive = total_consequtive + sum((floor(app.xcr(2, :)/app.DV) ~= floor(app.xcr(3, :)/app.DV)) & (floor(app.xcr(3, :)/app.DV) ~= floor(app.xcr(4, :)/app.DV))) + ...
                sum((floor(app.xcr(4, :)/app.DV) ~= floor(app.xcr(1, :)/app.DV)) & (floor(app.xcr(1, :)/app.DV) ~= floor(app.xcr(2, :)/app.DV)));
            
            total_con_over_int = total_consequtive/total_intersected;
			
			rt_estimate = 2 - total_con_over_int;
			UIUpdateOutEstimate(app, ['Sqrt(2) Estimate: ' num2str(rt_estimate)]);
		end
		
		function saveCurrentNeedles(app)
			file_name = ['needles_' char(randi([65 90],1,4)) '_task' app.currentTask '.mat'];
			
			[file, path, ~] = uiputfile('*.mat', 'Save Needles...', file_name);
			
			% Check if user cancelled
			if file == 0
				return;
			end
			
			% Get full file path
			filepath = fullfile(path, file);
			
			% What are we saving?
			ct = app.currentTask;
			tn = app.N;
			
			%sq_angles
			%n_angles
			
			if tn ~= 3
				sxc = app.xc;
				syc = app.yc;
				sxcr = app.xcr;
				sycr = app.ycr;
				snmd = [];
			else
				sxc = app.nxc;
				syc = app.nyc;
				sxcr = app.nxcr;
				sycr = app.nycr;
				snmd = app.nmd;
			end
			
			% Complete the save
			save(filepath, 'ct', 'tn', 'sxc', 'sxcr', 'syc', 'sycr', 'snmd');
		end
		
		function loadNewNeedles(app)
			[file, path] = uigetfile('*.mat');
			
			if isequal(file, 0)
				disp('User selected Cancel');
				return;
			end
			
			load(fullfile(path, file), 'ct', 'tn', 'sxc', 'sxcr', 'syc', 'sycr', 'snmd');
			
			% What are we loading?
			if app.overwriteOnImport == true
				app.N = tn;
				if ct ~= 3
					app.xc = sxc;
					app.yc = syc;
					app.xcr = sxcr;
					app.ycr = sycr;
				else
					app.nxc = sxc;
					app.nyc = syc;
					app.nxcr = sxcr;
					app.nycr = sycr;
					app.nmd = snmd;
				end
			else
				app.N = app.N + tn;
				if ct ~= 3
					app.xc = [app.xc, sxc];
					app.yc = [app.xc, syc];
					app.xcr = [app.xc, sxcr];
					app.ycr = [app.xc, sycr];
				else
					app.nxc = [app.xc, sxc];
					app.nyc = [app.xc, syc];
					app.nxcr = [app.xc, sxcr];
					app.nycr = [app.xc, sycr];
					app.nmd = [app.xc, snmd];
				end
			end
			
			% Show user new plot
			UIUpdateCurrentTask(app, ct);
			
			switch ct
				case 1
					set(app.ButtonTask1, 'Value', true);
				case 2
					set(app.ButtonTask2, 'Value', true);
				case 3
					set(app.ButtonTask3, 'Value', true);
				case 5
					set(app.ButtonTask5, 'Value', true);
			end
			
			if ct ~= 3
				plotSquares(app);
			else
				plotNeedles(app);
			end
		end
        
        function highlightNeedles(app)
            disp(app.highlightTask);
            if app.highlightTask == 1
                rehighlightClosestNeedles(app);
            elseif app.highlightTask == 2
                disp('4.2');
            end
        end
        
        function rehighlightClosestNeedles(app)
            removeHighlightClosestNeedles(app);
            highlightClosestNeedles(app);
        end
        
        function removeHighlightClosestNeedles(app)
            % Clear and re-plot without random regen
        end
        
        function highlightClosestNeedles(app)
            if isempty(app.lastClickedLine)
                disp('No line selected');
                return;
            end
            
            xd = app.lastClickedLine.XData;
            yd = app.lastClickedLine.YData;
            
            % Calculate gradient for this line
            md = (yd(1) - yd(2)) / (xd(1) - xd(2));
            
            % Compare to other lines
            diff = app.nmd - md;
            absdiff = abs(diff);
            absdiffsorted = sort(absdiff);
            
            % Find similar (we use 2:Similar+1 so as to not select original needle)
            nsim = absdiffsorted(2:(app.Similar+1));
            pos = ismember(absdiff, nsim);
			
			% Set this so we can change selected needle colours without re-drawing plot
			app.maskSimilar = pos;
            
            % Highlight n similar lines
            set(app.plt(pos), 'Color', app.uiSimilarPolyColor);
        end
		
		function UIUpdateOutEstimate(app, value)
			set(app.OutEstimateLabel, 'Text', value);
        end
        
        function UIDoClearAxes(app)
			cla(app.UIAxes, 'reset');
			axis(app.UIAxes, [0 1.0 0 1.0]);
        end
        
        function UIUpdateCurrentTask(app, newTaskNo)
            app.currentTask = newTaskNo;
			
			set(app.MinLengthOfNeedlesSlider, 'Visible', false);
			set(app.MinimumlengthofneedlesLabel, 'Visible', false);
            set(app.NHorizontalTilesSlider, 'Visible', false);
            set(app.NHorizontalTilesSliderLabel, 'Visible', false);
            set(app.SelectedNeedleControlsButtonGroup, 'Enable', 'off');
            set(app.roottwoButton, 'Enable', false);
            set(app.NeedlesButton, 'Enable', false);
            set(app.SquaresButton, 'Enable', true);
			set(app.changesReplotWarningLabel, 'Visible', false);
            
			if newTaskNo == 1
                set(app.NumberoffloorplanksSliderLabel, 'Text', 'Number of floor planks...');
				
				set(app.SquaresButton, 'Value', true);
				UIUpdateEstimationItem(app, 'Squares');
			end
            
			if newTaskNo == 2
                set(app.roottwoButton, 'Enable', true);
                set(app.NumberoffloorplanksSliderLabel, 'Text', 'Number of floor planks...');
				
				set(app.SquaresButton, 'Value', true);
				UIUpdateEstimationItem(app, 'Squares');
			end
            
			if newTaskNo == 3
                set(app.NeedlesButton, 'Enable', true);
                set(app.NHorizontalTilesSlider, 'Visible', true);
                set(app.NHorizontalTilesSliderLabel, 'Visible', true);
                set(app.SelectedNeedleControlsButtonGroup, 'Enable', 'on');
				set(app.piButton, 'Value', true);
				
				set(app.SquaresButton, 'Enable', false);
				set(app.NeedlesButton, 'Value', true);
				UIUpdateEstimationItem(app, 'Needles');
                
                set(app.NumberoffloorplanksSliderLabel, 'Text', 'M (Verticle tiles)');
			end
			
			if newTaskNo == 5
                set(app.NeedlesButton, 'Enable', true);
                set(app.SelectedNeedleControlsButtonGroup, 'Enable', 'on');
				set(app.piButton, 'Value', true);
				set(app.MinLengthOfNeedlesSlider, 'Visible', true);
				set(app.MinimumlengthofneedlesLabel, 'Visible', true);
				
				set(app.SquaresButton, 'Enable', false);
				set(app.NeedlesButton, 'Value', true);
				UIUpdateEstimationItem(app, 'Needles');
			end
			
			beginEstimation(app);
        end
		
        function UIUpdateEstimationItem(app, item)
            spinnerText = 'Number of Squares...';
            lengthText = 'Length of Square sides...';
            
            if strcmp(item, 'Needles')
                spinnerText = 'Number of Needles...';
				if app.currentTask == 5
					lengthText = 'Maximum length of Needles...';
				else
					lengthText = 'Length of Needles...';
				end
            end
            
            set(app.NumberofsquaresSpinnerLabel, 'Text', spinnerText);
            set(app.LengthofsquaresidesSliderLabel, 'Text', lengthText);
        end
        
        function UIChangeNeedleSelections(app, selected)
            set(app.nSpinner, 'Visible', false);
            set(app.nSpinnerLabel, 'Visible', false);
            
            switch selected
                case '1. Do nothing'
                    app.highlightTask = 0;
                case '2. Highlight similar angles'
                    app.highlightTask = 1;
                    set(app.nSpinner, 'Visible', true);
                    set(app.nSpinnerLabel, 'Visible', true);
                    highlightNeedles(app);
                case '3. Highlight closest'
                    app.highlightTask = 2;
            end
        end
		
		function LineSelected(app, src, evt)
            if ~isempty(app.lastClickedLine) && isvalid(app.lastClickedLine)
			    set(app.lastClickedLine, 'Color', app.lastClickedLineColor);
            end
            
            app.lastClickedLineColor = get(src, 'Color');
            app.lastClickedLine = src;
			set(src, 'Color', app.uiSelectedPolyColor);
            
            highlightNeedles(app);
		end
        
		function updatePlotFloor(app)
            app.gridlinesV = 1:app.NoVP+1;
            c = 0;
			for i = 0:app.DV:app.S
                c = c+1;
				app.gridlinesV(c) = xline(app.UIAxes, i,  '-', 'LineWidth', app.uiGridlineWidth, 'Color', app.uiGridlineColor);
			end
			
			if app.currentTask == 3
                app.gridlinesH = 1:app.NoHP+1;
                c = 0;
                for i = 0:app.DH:app.S
                    c = c+1;
					app.gridlinesH(c) = yline(app.UIAxes, i,  '-', 'LineWidth', app.uiGridlineWidth, 'Color', app.uiGridlineColor);
                end
			end
		end
	end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
			app.DV	=	app.S / app.NoVP;
			app.DH	=	app.S / app.NoVP;
			app.SL	=	app.DV / 2;
			app.RUB	=	app.SL;
			app.RLB	=	app.SL;
        end

        % Value changed function: NumberofitemSpinner
        function NumberofitemSpinnerValueChanged(app, event)
            value = ceil(app.NumberofitemSpinner.Value);
            updateItemCount(app, value);
        end

        % Value changed function: NumberoffloorplanksSlider
        function NumberoffloorplanksSliderValueChanged(app, event)
            value = app.NumberoffloorplanksSlider.Value;
            
            % Snap to nearest value
            [~, minVal] = min(abs(value - event.Source.MajorTicks(:)));
			event.Source.Value = event.Source.MajorTicks(minVal);
			
			updatePlankCount(app, minVal);
        end

        % Button pushed function: EstimateButton
        function EstimateButtonPushed(app, event)
			beginEstimation(app);
        end

        % Button pushed function: ModifyFontColourButton
        function ModifyFontColourButtonPushed(app, event)
            c = uisetcolor([0 0 0], 'Change font colour');
            
            set(app.OutEstimateLabel, 'FontColor', c);
            set(app.NumberofsquaresSpinnerLabel, 'FontColor', c);
			set(app.CurrentFontColorLamp, 'Color', c);
        end

        % Value changed function: FontSizeSlider
        function FontSizeSliderValueChanged(app, event)
            value = app.FontSizeSlider.Value;
            
            % Snap to nearest value (get ticks because interval is not 1)
            [~, minVal] = min(abs(value - event.Source.MajorTicks(:)));
			event.Source.Value = event.Source.MajorTicks(minVal);
            
            set(app.OutEstimateLabel, 'FontSize', value);
        end

        % Value changed function: LengthofitemsidesSlider
        function LengthofitemsidesSliderValueChanged(app, event)
            value = app.LengthofitemsidesSlider.Value;
            
            [~, minVal] = min(abs(value - event.Source.MajorTicks(:)));
			event.Source.Value = event.Source.MajorTicks(minVal);
            
			updateItemLength(app, minVal / 10);
        end

        % Button pushed function: ModifyGridLineColourButton
        function ModifyGridLineColourButtonPushed(app, event)
            c = uisetcolor([0 0 0], 'Change grid line colour');
            
            app.uiGridlineColor = c;
            
            set(app.CurrentGridLineColour, 'Color', c);
            set(app.gridlinesV, 'Color', c);
            
            if ~isempty(app.gridlinesH)
                set(app.gridlinesH, 'Color', c);
            end
        end

        % Selection changed function: EstimatevalueofButtonGroup
        function EstimatevalueofButtonGroupSelectionChanged(app, event)
            selectedButton = app.EstimatevalueofButtonGroup.SelectedObject;
            
            if strcmp(selectedButton.Text,'π - "pi"')
                app.calc = 1;
            else
                app.calc = 2;
            end
            
            beginEstimation(app);
        end

        % Value changed function: NHorizontalTilesSlider
        function NHorizontalTilesSliderValueChanged(app, event)
            value = app.NHorizontalTilesSlider.Value;
            
            % Snap to nearest value
            [~, minVal] = min(abs(value - event.Source.MajorTicks(:)));
			event.Source.Value = event.Source.MajorTicks(minVal);
            
            updateHorizontalPlankCount(app, minVal);
        end

        % Value changed function: GridLineThicknessSpinner
        function GridLineThicknessSpinnerValueChanged(app, event)
            value = app.GridLineThicknessSpinner.Value;
            app.uiGridlineWidth = value;
            
            set(app.gridlinesV, 'LineWidth', value);
            if ~isempty(app.gridlinesH)
                set(app.gridlinesH, 'LineWidth', value);
            end
        end

        % Selection changed function: SelectTaskButtonGroup
        function SelectTaskButtonGroupSelectionChanged(app, event)
            selectedButton = app.SelectTaskButtonGroup.SelectedObject;
            UIUpdateCurrentTask(app, str2num(selectedButton.Text));
        end

        % Selection changed function: EstimatevalueusingButtonGroup
        function EstimatevalueusingButtonGroupSelectionChanged(app, event)
            selectedButton = app.EstimatevalueusingButtonGroup.SelectedObject;
            UIUpdateEstimationItem(app, selectedButton.Text);
        end

        % Button pushed function: ModifyShapeColourIntersectButton
        function ModifyShapeColourIntersectButtonPushed(app, event)
            c = uisetcolor([1 0 0], 'Change intersecting shape colour');
			set(app.CurrentShapeColourIntersect, 'Color', c);
            
			if app.currentTask == 3
				set(app.plt(app.maskIntersecting), 'Color', c);
			else
				set(app.changesReplotWarningLabel, 'Visible', true);
			end
			
            app.uiIntersectPolyColor = c;
        end

        % Button pushed function: 
        % ModifyShapeColourNonIntersectButton
        function ModifyShapeColourNonIntersectButtonPushed(app, event)
            c = uisetcolor([0 1 0], 'Change non-intersecting shape colour');
			set(app.CurrentShapeColourNonIntersect, 'Color', c);
            
			if app.currentTask == 3
				set(app.plt(~app.maskIntersecting), 'Color', c);
			else
				set(app.changesReplotWarningLabel, 'Visible', true);
			end
			
            app.uiNonIntersectPolyColor = c;
        end

        % Button pushed function: ModifyShapeColourSelectedButton
        function ModifyShapeColourSelectedButtonPushed(app, event)
            c = uisetcolor([0 0 1], 'Change selected needle colour');
			set(app.CurrentShapeColourSelected, 'Color', c);
			set(app.lastClickedLine, 'Color', c);
			
            app.uiSelectedPolyColor = c;
        end

        % Button pushed function: ModifyShapeColourSimilarButton
        function ModifyShapeColourSimilarButtonPushed(app, event)
            c = uisetcolor([0.72, 0.27, 1.00], 'Change similar needle colour');
			set(app.CurrentShapeColourSelected, 'Color', c);
            set(app.plt(app.maskSimilar), 'Color', c);
			
            app.uiSimilarPolyColor = c;
        end

        % Selection changed function: 
        % SelectedNeedleControlsButtonGroup
        function SelectedNeedleControlsButtonGroupSelectionChanged(app, event)
            selectedButton = app.SelectedNeedleControlsButtonGroup.SelectedObject;
            
            UIChangeNeedleSelections(app, selectedButton.Text);
        end

        % Value changed function: nSpinner
        function nSpinnerValueChanged(app, event)
            value = app.nSpinner.Value;
            app.Similar = value;
            rehighlightClosestNeedles(app);
        end

        % Value changed function: MinLengthOfNeedlesSlider
        function MinLengthOfNeedlesSliderValueChanged(app, event)
            value = app.MinLengthOfNeedlesSlider.Value;
			
            [~, minVal] = min(abs(value - event.Source.MajorTicks(:)));
			event.Source.Value = event.Source.MajorTicks(minVal);
			
            app.RLB = minVal/10;
			
			beginEstimation(app);
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
			UIDoClearAxes(app);
			UIUpdateOutEstimate(app, 'Figure was cleared');
        end

        % Button pushed function: ModifyFigureBackgroundColourButton
        function ModifyFigureBackgroundColourButtonPushed(app, event)
            c = uisetcolor([1, 1, 1], 'Change figure background colour');
			set(app.CurrentFigureBackgroundColour, 'Color', c);
            set(app.UIAxes, 'Color', c);
        end

        % Button pushed function: ExportCurrentNeedlesButton
        function ExportCurrentNeedlesButtonPushed(app, event)
			saveCurrentNeedles(app);
        end

        % Value changed function: NeedleLineThicknessSpinner
        function NeedleLineThicknessSpinnerValueChanged(app, event)
            value = app.NeedleLineThicknessSpinner.Value;
			
			app.uiNeedleLineWidth = value;
            set(app.plt, 'LineWidth', value);
        end

        % Button pushed function: ImportNewNeedlesButton
        function ImportNewNeedlesButtonPushed(app, event)
            loadNewNeedles(app);
        end

        % Selection changed function: 
        % OverwritecurrentplotonimportButtonGroup
        function OverwritecurrentplotonimportButtonGroupSelectionChanged(app, event)
            selectedButton = app.OverwritecurrentplotonimportButtonGroup.SelectedObject;
			
            app.overwriteOnImport = true;
			if strcmp(selectedButton.Text, 'No')
				app.overwriteOnImport = false;
			end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 840 518];
            app.UIFigure.Name = 'MATLAB App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', 539.5};
            app.GridLayout.RowHeight = {469, 22, 27};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = [1 3];
            app.TabGroup.Layout.Column = 1;

            % Create PlotControlsTab
            app.PlotControlsTab = uitab(app.TabGroup);
            app.PlotControlsTab.Title = 'Plot Controls';

            % Create EstimatevalueusingButtonGroup
            app.EstimatevalueusingButtonGroup = uibuttongroup(app.PlotControlsTab);
            app.EstimatevalueusingButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @EstimatevalueusingButtonGroupSelectionChanged, true);
            app.EstimatevalueusingButtonGroup.Title = 'Estimate value using...';
            app.EstimatevalueusingButtonGroup.Position = [152 333 147 95];

            % Create SquaresButton
            app.SquaresButton = uiradiobutton(app.EstimatevalueusingButtonGroup);
            app.SquaresButton.Text = 'Squares';
            app.SquaresButton.Position = [11 49 67 22];
            app.SquaresButton.Value = true;

            % Create NeedlesButton
            app.NeedlesButton = uiradiobutton(app.EstimatevalueusingButtonGroup);
            app.NeedlesButton.Enable = 'off';
            app.NeedlesButton.Text = 'Needles';
            app.NeedlesButton.Position = [11 27 66 22];

            % Create BestagonsButton
            app.BestagonsButton = uiradiobutton(app.EstimatevalueusingButtonGroup);
            app.BestagonsButton.Visible = 'off';
            app.BestagonsButton.Text = 'Bestagons';
            app.BestagonsButton.Position = [11 5 79 22];

            % Create NumberofsquaresSpinnerLabel
            app.NumberofsquaresSpinnerLabel = uilabel(app.PlotControlsTab);
            app.NumberofsquaresSpinnerLabel.HorizontalAlignment = 'right';
            app.NumberofsquaresSpinnerLabel.Position = [152 303 117 22];
            app.NumberofsquaresSpinnerLabel.Text = 'Number of squares...';

            % Create NumberofitemSpinner
            app.NumberofitemSpinner = uispinner(app.PlotControlsTab);
            app.NumberofitemSpinner.Limits = [1 10000000];
            app.NumberofitemSpinner.ValueChangedFcn = createCallbackFcn(app, @NumberofitemSpinnerValueChanged, true);
            app.NumberofitemSpinner.HorizontalAlignment = 'left';
            app.NumberofitemSpinner.Position = [156 282 142 22];
            app.NumberofitemSpinner.Value = 750;

            % Create NumberoffloorplanksSliderLabel
            app.NumberoffloorplanksSliderLabel = uilabel(app.PlotControlsTab);
            app.NumberoffloorplanksSliderLabel.HorizontalAlignment = 'right';
            app.NumberoffloorplanksSliderLabel.Position = [6 303 136 22];
            app.NumberoffloorplanksSliderLabel.Text = 'Number of floor planks...';

            % Create NumberoffloorplanksSlider
            app.NumberoffloorplanksSlider = uislider(app.PlotControlsTab);
            app.NumberoffloorplanksSlider.Limits = [1 10];
            app.NumberoffloorplanksSlider.MajorTicks = [1 2 3 4 5 6 7 8 9 10];
            app.NumberoffloorplanksSlider.MajorTickLabels = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};
            app.NumberoffloorplanksSlider.ValueChangedFcn = createCallbackFcn(app, @NumberoffloorplanksSliderValueChanged, true);
            app.NumberoffloorplanksSlider.MinorTicks = [];
            app.NumberoffloorplanksSlider.Position = [10 293 136 7];
            app.NumberoffloorplanksSlider.Value = 5;

            % Create EstimatevalueofButtonGroup
            app.EstimatevalueofButtonGroup = uibuttongroup(app.PlotControlsTab);
            app.EstimatevalueofButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @EstimatevalueofButtonGroupSelectionChanged, true);
            app.EstimatevalueofButtonGroup.Title = 'Estimate value of...';
            app.EstimatevalueofButtonGroup.Position = [7 334 141 95];

            % Create piButton
            app.piButton = uiradiobutton(app.EstimatevalueofButtonGroup);
            app.piButton.Text = 'π - "pi"';
            app.piButton.Position = [11 49 59 22];
            app.piButton.Value = true;

            % Create roottwoButton
            app.roottwoButton = uiradiobutton(app.EstimatevalueofButtonGroup);
            app.roottwoButton.Enable = 'off';
            app.roottwoButton.Text = '√2 - "root two"';
            app.roottwoButton.Position = [11 27 97 22];

            % Create goldenratioButton
            app.goldenratioButton = uiradiobutton(app.EstimatevalueofButtonGroup);
            app.goldenratioButton.Visible = 'off';
            app.goldenratioButton.Text = 'ϕ - "golden ratio"';
            app.goldenratioButton.Position = [10 1 110 22];

            % Create EstimateButton
            app.EstimateButton = uibutton(app.PlotControlsTab, 'push');
            app.EstimateButton.ButtonPushedFcn = createCallbackFcn(app, @EstimateButtonPushed, true);
            app.EstimateButton.Interruptible = 'off';
            app.EstimateButton.FontSize = 18;
            app.EstimateButton.Position = [179 41 100 29];
            app.EstimateButton.Text = 'Estimate';

            % Create LengthofsquaresidesSliderLabel
            app.LengthofsquaresidesSliderLabel = uilabel(app.PlotControlsTab);
            app.LengthofsquaresidesSliderLabel.Position = [14 166 174 22];
            app.LengthofsquaresidesSliderLabel.Text = 'Length of square sides:';

            % Create LengthofitemsidesSlider
            app.LengthofitemsidesSlider = uislider(app.PlotControlsTab);
            app.LengthofitemsidesSlider.Limits = [1 10];
            app.LengthofitemsidesSlider.MajorTicks = [1 2 3 4 5 6 7 8 9 10];
            app.LengthofitemsidesSlider.MajorTickLabels = {'0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1.0'};
            app.LengthofitemsidesSlider.ValueChangedFcn = createCallbackFcn(app, @LengthofitemsidesSliderValueChanged, true);
            app.LengthofitemsidesSlider.MinorTicks = [];
            app.LengthofitemsidesSlider.Position = [18 155 267 7];
            app.LengthofitemsidesSlider.Value = 1;

            % Create WarningSquarelengthPlankdistanceLabel
            app.WarningSquarelengthPlankdistanceLabel = uilabel(app.PlotControlsTab);
            app.WarningSquarelengthPlankdistanceLabel.FontColor = [1 0 0];
            app.WarningSquarelengthPlankdistanceLabel.Visible = 'off';
            app.WarningSquarelengthPlankdistanceLabel.Position = [25 180 228 22];
            app.WarningSquarelengthPlankdistanceLabel.Text = 'Warning! Square length > Plank distance ';

            % Create NHorizontalTilesSliderLabel
            app.NHorizontalTilesSliderLabel = uilabel(app.PlotControlsTab);
            app.NHorizontalTilesSliderLabel.HorizontalAlignment = 'right';
            app.NHorizontalTilesSliderLabel.Visible = 'off';
            app.NHorizontalTilesSliderLabel.Position = [51 236 107 22];
            app.NHorizontalTilesSliderLabel.Text = 'N (Horizontal Tiles)';

            % Create NHorizontalTilesSlider
            app.NHorizontalTilesSlider = uislider(app.PlotControlsTab);
            app.NHorizontalTilesSlider.Limits = [1 10];
            app.NHorizontalTilesSlider.MajorTicks = [1 2 3 4 5 6 7 8 9 10];
            app.NHorizontalTilesSlider.MajorTickLabels = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};
            app.NHorizontalTilesSlider.ValueChangedFcn = createCallbackFcn(app, @NHorizontalTilesSliderValueChanged, true);
            app.NHorizontalTilesSlider.MinorTicks = [];
            app.NHorizontalTilesSlider.Visible = 'off';
            app.NHorizontalTilesSlider.Position = [10 225 135 7];
            app.NHorizontalTilesSlider.Value = 5;

            % Create SelectTaskButtonGroup
            app.SelectTaskButtonGroup = uibuttongroup(app.PlotControlsTab);
            app.SelectTaskButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @SelectTaskButtonGroupSelectionChanged, true);
            app.SelectTaskButtonGroup.Title = 'Select Task';
            app.SelectTaskButtonGroup.Position = [23 433 255 50];

            % Create ButtonTask1
            app.ButtonTask1 = uitogglebutton(app.SelectTaskButtonGroup);
            app.ButtonTask1.Text = '1';
            app.ButtonTask1.Position = [9 5 54 22];
            app.ButtonTask1.Value = true;

            % Create ButtonTask2
            app.ButtonTask2 = uitogglebutton(app.SelectTaskButtonGroup);
            app.ButtonTask2.Text = '2';
            app.ButtonTask2.Position = [73 5 49 22];

            % Create ButtonTask3
            app.ButtonTask3 = uitogglebutton(app.SelectTaskButtonGroup);
            app.ButtonTask3.Text = '3';
            app.ButtonTask3.Position = [133 5 51 22];

            % Create ButtonTask5
            app.ButtonTask5 = uitogglebutton(app.SelectTaskButtonGroup);
            app.ButtonTask5.Text = '5';
            app.ButtonTask5.Position = [194 5 51 22];

            % Create SelectedNeedleControlsButtonGroup
            app.SelectedNeedleControlsButtonGroup = uibuttongroup(app.PlotControlsTab);
            app.SelectedNeedleControlsButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @SelectedNeedleControlsButtonGroupSelectionChanged, true);
            app.SelectedNeedleControlsButtonGroup.Enable = 'off';
            app.SelectedNeedleControlsButtonGroup.Title = 'Selected Needle Controls';
            app.SelectedNeedleControlsButtonGroup.Position = [7 3 157 106];

            % Create DonothingButton
            app.DonothingButton = uitogglebutton(app.SelectedNeedleControlsButtonGroup);
            app.DonothingButton.Text = '1. Do nothing';
            app.DonothingButton.Position = [3 55 151 22];
            app.DonothingButton.Value = true;

            % Create HighlightsimilaranglesButton
            app.HighlightsimilaranglesButton = uitogglebutton(app.SelectedNeedleControlsButtonGroup);
            app.HighlightsimilaranglesButton.Text = '2. Highlight similar angles';
            app.HighlightsimilaranglesButton.Position = [2 32 152 22];

            % Create HighlightclosestButton
            app.HighlightclosestButton = uitogglebutton(app.SelectedNeedleControlsButtonGroup);
            app.HighlightclosestButton.Text = '3. Highlight closest';
            app.HighlightclosestButton.Position = [3 9 151 22];

            % Create nSpinnerLabel
            app.nSpinnerLabel = uilabel(app.PlotControlsTab);
            app.nSpinnerLabel.HorizontalAlignment = 'right';
            app.nSpinnerLabel.Visible = 'off';
            app.nSpinnerLabel.Position = [196 87 25 22];
            app.nSpinnerLabel.Text = 'n';

            % Create nSpinner
            app.nSpinner = uispinner(app.PlotControlsTab);
            app.nSpinner.Limits = [1 100];
            app.nSpinner.ValueChangedFcn = createCallbackFcn(app, @nSpinnerValueChanged, true);
            app.nSpinner.Visible = 'off';
            app.nSpinner.Position = [229 87 50 22];
            app.nSpinner.Value = 3;

            % Create MinimumlengthofneedlesLabel
            app.MinimumlengthofneedlesLabel = uilabel(app.PlotControlsTab);
            app.MinimumlengthofneedlesLabel.Visible = 'off';
            app.MinimumlengthofneedlesLabel.Position = [12 236 148 22];
            app.MinimumlengthofneedlesLabel.Text = 'Minimum length of needles';

            % Create MinLengthOfNeedlesSlider
            app.MinLengthOfNeedlesSlider = uislider(app.PlotControlsTab);
            app.MinLengthOfNeedlesSlider.Limits = [1 10];
            app.MinLengthOfNeedlesSlider.MajorTicks = [1 2 3 4 5 6 7 8 9 10];
            app.MinLengthOfNeedlesSlider.MajorTickLabels = {'0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1.0'};
            app.MinLengthOfNeedlesSlider.ValueChangedFcn = createCallbackFcn(app, @MinLengthOfNeedlesSliderValueChanged, true);
            app.MinLengthOfNeedlesSlider.MinorTicks = [];
            app.MinLengthOfNeedlesSlider.Visible = 'off';
            app.MinLengthOfNeedlesSlider.Position = [16 224 267 7];
            app.MinLengthOfNeedlesSlider.Value = 1;

            % Create ClearButton
            app.ClearButton = uibutton(app.PlotControlsTab, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Interruptible = 'off';
            app.ClearButton.FontSize = 18;
            app.ClearButton.Position = [179 7 100 29];
            app.ClearButton.Text = 'Clear';

            % Create UIControlsTab
            app.UIControlsTab = uitab(app.TabGroup);
            app.UIControlsTab.Title = 'UI Controls';

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.UIControlsTab);
            app.TabGroup2.Position = [0 1 301 494];

            % Create OutputTab
            app.OutputTab = uitab(app.TabGroup2);
            app.OutputTab.Title = 'Output';

            % Create FontSizeSliderLabel
            app.FontSizeSliderLabel = uilabel(app.OutputTab);
            app.FontSizeSliderLabel.HorizontalAlignment = 'right';
            app.FontSizeSliderLabel.Position = [123 442 56 22];
            app.FontSizeSliderLabel.Text = 'Font Size';

            % Create FontSizeSlider
            app.FontSizeSlider = uislider(app.OutputTab);
            app.FontSizeSlider.Limits = [12 20];
            app.FontSizeSlider.MajorTicks = [12 14 16 18 20];
            app.FontSizeSlider.MajorTickLabels = {'XS', 'S', 'M', 'L', 'XL'};
            app.FontSizeSlider.ValueChangedFcn = createCallbackFcn(app, @FontSizeSliderValueChanged, true);
            app.FontSizeSlider.MinorTicks = [];
            app.FontSizeSlider.Position = [23 432 256 7];
            app.FontSizeSlider.Value = 14;

            % Create ModifyFontColourButton
            app.ModifyFontColourButton = uibutton(app.OutputTab, 'push');
            app.ModifyFontColourButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyFontColourButtonPushed, true);
            app.ModifyFontColourButton.Position = [67 359 137 22];
            app.ModifyFontColourButton.Text = 'Modify Font Colour';

            % Create CurrentFontColorLamp
            app.CurrentFontColorLamp = uilamp(app.OutputTab);
            app.CurrentFontColorLamp.Position = [23 358 25 25];
            app.CurrentFontColorLamp.Color = [0 0 0];

            % Create SwitchLabel
            app.SwitchLabel = uilabel(app.OutputTab);
            app.SwitchLabel.HorizontalAlignment = 'center';
            app.SwitchLabel.WordWrap = 'on';
            app.SwitchLabel.Position = [85 117 194 50];
            app.SwitchLabel.Text = 'Automatically re-run simulation when an important value changes';

            % Create AutoRerunSimulation
            app.AutoRerunSimulation = uiswitch(app.OutputTab, 'slider');
            app.AutoRerunSimulation.Position = [45 137 21 9];

            % Create FigureTab
            app.FigureTab = uitab(app.TabGroup2);
            app.FigureTab.Title = 'Figure';

            % Create ModifyShapeColourNonIntersectButton
            app.ModifyShapeColourNonIntersectButton = uibutton(app.FigureTab, 'push');
            app.ModifyShapeColourNonIntersectButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyShapeColourNonIntersectButtonPushed, true);
            app.ModifyShapeColourNonIntersectButton.Position = [48 278 229 22];
            app.ModifyShapeColourNonIntersectButton.Text = 'Modify Non-intersecting Polygon Colour';

            % Create CurrentShapeColourNonIntersect
            app.CurrentShapeColourNonIntersect = uilamp(app.FigureTab);
            app.CurrentShapeColourNonIntersect.Position = [16 277 25 25];

            % Create ModifyShapeColourIntersectButton
            app.ModifyShapeColourIntersectButton = uibutton(app.FigureTab, 'push');
            app.ModifyShapeColourIntersectButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyShapeColourIntersectButtonPushed, true);
            app.ModifyShapeColourIntersectButton.Position = [61 312 204 22];
            app.ModifyShapeColourIntersectButton.Text = 'Modify Intersecting Polygon Colour';

            % Create CurrentShapeColourIntersect
            app.CurrentShapeColourIntersect = uilamp(app.FigureTab);
            app.CurrentShapeColourIntersect.Position = [16 312 25 25];
            app.CurrentShapeColourIntersect.Color = [1 0 0];

            % Create ModifyGridLineColourButton
            app.ModifyGridLineColourButton = uibutton(app.FigureTab, 'push');
            app.ModifyGridLineColourButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyGridLineColourButtonPushed, true);
            app.ModifyGridLineColourButton.Position = [92 377 142 22];
            app.ModifyGridLineColourButton.Text = 'Modify Grid Line Colour';

            % Create CurrentGridLineColour
            app.CurrentGridLineColour = uilamp(app.FigureTab);
            app.CurrentGridLineColour.Position = [16 376 25 25];
            app.CurrentGridLineColour.Color = [0 0 0];

            % Create GridLineThicknessSpinnerLabel
            app.GridLineThicknessSpinnerLabel = uilabel(app.FigureTab);
            app.GridLineThicknessSpinnerLabel.HorizontalAlignment = 'right';
            app.GridLineThicknessSpinnerLabel.Position = [31 437 111 22];
            app.GridLineThicknessSpinnerLabel.Text = 'Grid Line Thickness';

            % Create GridLineThicknessSpinner
            app.GridLineThicknessSpinner = uispinner(app.FigureTab);
            app.GridLineThicknessSpinner.Limits = [1 5];
            app.GridLineThicknessSpinner.ValueChangedFcn = createCallbackFcn(app, @GridLineThicknessSpinnerValueChanged, true);
            app.GridLineThicknessSpinner.Position = [157 437 100 22];
            app.GridLineThicknessSpinner.Value = 1;

            % Create ModifyShapeColourSelectedButton
            app.ModifyShapeColourSelectedButton = uibutton(app.FigureTab, 'push');
            app.ModifyShapeColourSelectedButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyShapeColourSelectedButtonPushed, true);
            app.ModifyShapeColourSelectedButton.Position = [73 244 181 22];
            app.ModifyShapeColourSelectedButton.Text = 'Modify Selected Needle Colour';

            % Create CurrentShapeColourSelected
            app.CurrentShapeColourSelected = uilamp(app.FigureTab);
            app.CurrentShapeColourSelected.Position = [16 243 25 25];
            app.CurrentShapeColourSelected.Color = [0 0 1];

            % Create ModifyShapeColourSimilarButton
            app.ModifyShapeColourSimilarButton = uibutton(app.FigureTab, 'push');
            app.ModifyShapeColourSimilarButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyShapeColourSimilarButtonPushed, true);
            app.ModifyShapeColourSimilarButton.Position = [73 212 181 22];
            app.ModifyShapeColourSimilarButton.Text = 'Modify Similar Needle Colour';

            % Create CurrentShapeColourSimilar
            app.CurrentShapeColourSimilar = uilamp(app.FigureTab);
            app.CurrentShapeColourSimilar.Position = [16 211 25 25];
            app.CurrentShapeColourSimilar.Color = [0.7216 0.2706 1];

            % Create changesReplotWarningLabel
            app.changesReplotWarningLabel = uilabel(app.FigureTab);
            app.changesReplotWarningLabel.FontSize = 11;
            app.changesReplotWarningLabel.FontColor = [1 0 0];
            app.changesReplotWarningLabel.Visible = 'off';
            app.changesReplotWarningLabel.Position = [7 179 313 27];
            app.changesReplotWarningLabel.Text = '* These changes will be applied once you re-plot the figure';

            % Create CurrentFigureBackgroundColour
            app.CurrentFigureBackgroundColour = uilamp(app.FigureTab);
            app.CurrentFigureBackgroundColour.Position = [16 343 25 25];
            app.CurrentFigureBackgroundColour.Color = [1 1 1];

            % Create ModifyFigureBackgroundColourButton
            app.ModifyFigureBackgroundColourButton = uibutton(app.FigureTab, 'push');
            app.ModifyFigureBackgroundColourButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyFigureBackgroundColourButtonPushed, true);
            app.ModifyFigureBackgroundColourButton.Position = [66 344 195 22];
            app.ModifyFigureBackgroundColourButton.Text = 'Modify Figure Background Colour';

            % Create NeedleLineThicknessSpinnerLabel
            app.NeedleLineThicknessSpinnerLabel = uilabel(app.FigureTab);
            app.NeedleLineThicknessSpinnerLabel.HorizontalAlignment = 'right';
            app.NeedleLineThicknessSpinnerLabel.Position = [16 406 127 22];
            app.NeedleLineThicknessSpinnerLabel.Text = 'Needle Line Thickness';

            % Create NeedleLineThicknessSpinner
            app.NeedleLineThicknessSpinner = uispinner(app.FigureTab);
            app.NeedleLineThicknessSpinner.Step = 0.5;
            app.NeedleLineThicknessSpinner.Limits = [1 5];
            app.NeedleLineThicknessSpinner.ValueChangedFcn = createCallbackFcn(app, @NeedleLineThicknessSpinnerValueChanged, true);
            app.NeedleLineThicknessSpinner.Position = [158 406 100 22];
            app.NeedleLineThicknessSpinner.Value = 2;

            % Create FilesTab
            app.FilesTab = uitab(app.TabGroup);
            app.FilesTab.Title = 'Files';

            % Create ImportNewNeedlesButton
            app.ImportNewNeedlesButton = uibutton(app.FilesTab, 'push');
            app.ImportNewNeedlesButton.ButtonPushedFcn = createCallbackFcn(app, @ImportNewNeedlesButtonPushed, true);
            app.ImportNewNeedlesButton.Position = [153 192 141 22];
            app.ImportNewNeedlesButton.Text = 'Import New Needles';

            % Create ExportCurrentNeedlesButton
            app.ExportCurrentNeedlesButton = uibutton(app.FilesTab, 'push');
            app.ExportCurrentNeedlesButton.ButtonPushedFcn = createCallbackFcn(app, @ExportCurrentNeedlesButtonPushed, true);
            app.ExportCurrentNeedlesButton.Position = [152 378 141 22];
            app.ExportCurrentNeedlesButton.Text = 'Export Current Needles';

            % Create OverwritecurrentplotonimportButtonGroup
            app.OverwritecurrentplotonimportButtonGroup = uibuttongroup(app.FilesTab);
            app.OverwritecurrentplotonimportButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @OverwritecurrentplotonimportButtonGroupSelectionChanged, true);
            app.OverwritecurrentplotonimportButtonGroup.Title = 'Overwrite current plot on import?';
            app.OverwritecurrentplotonimportButtonGroup.Position = [12 225 273 55];

            % Create YesButton
            app.YesButton = uitogglebutton(app.OverwritecurrentplotonimportButtonGroup);
            app.YesButton.Text = 'Yes';
            app.YesButton.Position = [11 7 100 22];
            app.YesButton.Value = true;

            % Create NoButton
            app.NoButton = uitogglebutton(app.OverwritecurrentplotonimportButtonGroup);
            app.NoButton.Text = 'No';
            app.NoButton.Position = [114 7 100 22];

            % Create SaveCurrentPlotLabel
            app.SaveCurrentPlotLabel = uilabel(app.FilesTab);
            app.SaveCurrentPlotLabel.FontSize = 16;
            app.SaveCurrentPlotLabel.Position = [14 462 131 22];
            app.SaveCurrentPlotLabel.Text = 'Save Current Plot';

            % Create LoadExportedPlotLabel
            app.LoadExportedPlotLabel = uilabel(app.FilesTab);
            app.LoadExportedPlotLabel.FontSize = 16;
            app.LoadExportedPlotLabel.Position = [16 333 141 22];
            app.LoadExportedPlotLabel.Text = 'Load Exported Plot';

            % Create LoadExportedDescLabel
            app.LoadExportedDescLabel = uilabel(app.FilesTab);
            app.LoadExportedDescLabel.WordWrap = 'on';
            app.LoadExportedDescLabel.Position = [17 293 269 32];
            app.LoadExportedDescLabel.Text = 'This option allows you to load previously saved needles in order to improve your estimate.';

            % Create LoadExportedDescLabel_2
            app.LoadExportedDescLabel_2 = uilabel(app.FilesTab);
            app.LoadExportedDescLabel_2.WordWrap = 'on';
            app.LoadExportedDescLabel_2.Position = [16 420 269 32];
            app.LoadExportedDescLabel_2.Text = 'Saving Needles right now will mean that all 0 needles from task 3 will be exported.';

            % Create OutEstimateLabel
            app.OutEstimateLabel = uilabel(app.GridLayout);
            app.OutEstimateLabel.FontSize = 16;
            app.OutEstimateLabel.Layout.Row = 2;
            app.OutEstimateLabel.Layout.Column = 2;
            app.OutEstimateLabel.Text = 'Pi Estimate: N/A';

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Floor')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = basic_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
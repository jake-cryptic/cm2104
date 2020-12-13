classdef basic_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
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
        PlottingStatusLampLabel         matlab.ui.control.Label
        PlottingStatusLamp              matlab.ui.control.Lamp
        LengthofsquaresidesSliderLabel  matlab.ui.control.Label
        LengthofitemsidesSlider         matlab.ui.control.Slider
        WarningSquarelengthPlankdistanceLabel  matlab.ui.control.Label
        NHorizontalTilesSliderLabel     matlab.ui.control.Label
        NHorizontalTilesSlider          matlab.ui.control.Slider
        SelectTaskButtonGroup           matlab.ui.container.ButtonGroup
        ButtonTask1                     matlab.ui.control.ToggleButton
        ButtonTask2                     matlab.ui.control.ToggleButton
        ButtonTask3                     matlab.ui.control.ToggleButton
        SelectedNeedleControlsButtonGroup  matlab.ui.container.ButtonGroup
        DonothingButton                 matlab.ui.control.ToggleButton
        HighlightclosestButton          matlab.ui.control.ToggleButton
        HighlightsimilaranglesButton    matlab.ui.control.ToggleButton
        nSpinnerLabel                   matlab.ui.control.Label
        nSpinner                        matlab.ui.control.Spinner
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
        OutEstimateLabel                matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
		calc    =   1                   % What are we calculating? 1 = pi, 2 = sqrt(2)
        S	    =	1					% Scale factor
        N	    =	200			     % Number of shapes
		NoVP	=	5				    % Number of planks
        NoHP    =   5                   % Number of horizontal planks
		DV							    % Distance between vertical planks
		DH							    % Distance between horizontal planks
		SL							    % Length of shape
        
        % Custom variables
        uiGridlineWidth =   1
        uiGridlineColor = [0 0 0]
        uiSelectedPolyColor = [0 0 1]
        uiIntersectPolyColor = [1 0 0]
        uiNonIntersectPolyColor = [0 1 0]
        uiSimilarPolyColor = [0.72 0.27 1.0]
        currentTask = 1
		
		% Patch object
		pat
        plt
        plti
        
        gridlinesH
        gridlinesV
        
        lastClickedLine
        lastClickedLineColor = [0 0 0]
		
		% State variables
		sq_angles
		xc
		yc
		xcr
		ycr
        
		n_angles
		nxc
		nyc
		nxcr
		nycr
    end
    
    methods (Access = private)
        
		function beginEstimation(app)
            if app.currentTask == 1 || app.currentTask == 2
			    updateSquarePlot(app);
            else
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
			app.SL = itemLength;
            makeWarningForLgtD(app);
			beginEstimation(app);
        end
        
        function updateNeedleRanomisation(app)
			app.n_angles = rand(1, app.N) * 360;
			app.nxc = app.SL + rand(1, app.N) * (app.S - 2 * app.SL);
			app.nyc = app.SL + rand(1, app.N) * (app.S - 2 * app.SL);
		end
		
		function updateNeedlePlot(app)
			UIDoClearAxes(app);
			updateNeedleRanomisation(app);
			
			app.nxcr = app.nxc + app.SL * cosd(app.n_angles);
			app.nycr = app.nyc + app.SL * sind(app.n_angles);
			
			calculateNeedlePi(app);
            
			intersecting = (floor(app.nyc / app.DH) ~= floor(app.nycr / app.DH)) | (floor(app.nxc / app.DV) ~= floor(app.nxcr / app.DV));
			
            hold(app.UIAxes, 'on');
            app.plt = plot(app.UIAxes, [app.nxc(intersecting); app.nxcr(intersecting)], [app.nyc(intersecting); app.nycr(intersecting)], 'LineWidth', 2, 'Color', app.uiIntersectPolyColor);
            app.plti = plot(app.UIAxes, [app.nxc(~intersecting); app.nxcr(~intersecting)], [app.nyc(~intersecting); app.nycr(~intersecting)], 'LineWidth', 2, 'Color', app.uiNonIntersectPolyColor);
            hold(app.UIAxes, 'off');
            
			set(app.plt, 'ButtonDownFcn', @app.LineSelected);
			set(app.plti, 'ButtonDownFcn', @app.LineSelected);
			
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
			
            if app.calc == 1
			    calculateSquarePi(app);
            else
                calculateSquareSqrtTwo(app);
            end
            
            intersecting = floor(app.xcr(1, :)/app.DV) ~= floor(app.xcr(2, :)/app.DV) | floor(app.xcr(2, :)/app.DV) ~= floor(app.xcr(3, :)/app.DV) |...
                floor(app.xcr(3, :)/app.DV) ~= floor(app.xcr(4, :)/app.DV) | floor(app.xcr(4, :)/app.DV) ~= floor(app.xcr(1, :)/app.DV);
			
			app.pat = patch(app.UIAxes, app.xcr(:,intersecting), app.ycr(:,intersecting), 'w', 'EdgeColor', app.uiIntersectPolyColor);
            app.pat = [app.pat, patch(app.UIAxes, app.xcr(:,~intersecting), app.ycr(:,~intersecting), 'w', 'EdgeColor', app.uiNonIntersectPolyColor)];
		end
		
		function calculateNeedlePi(app)
			n = 0;
			n = n + sum((floor(app.nyc / app.DH) ~= floor(app.nycr / app.DH)) | floor(app.nxc / app.DV) ~= floor(app.nxcr / app.DV));
		
			p = (n/app.N);
			a = app.DH;
			b = app.DV;
			
			pi_estimate = ((2 * app.SL * (a + b)) - app.SL^2) / (p * a * b);
			UIUpdateOutEstimate(app, ['Needle Pi Estimate: ' num2str(pi_estimate)]);
		end
		
		function calculateSquarePi(app)
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
            total_intersected = sum(floor(app.xcr(1, :)/app.DV) ~= floor(app.xcr(2, :)/app.DV) | floor(app.xcr(2, :)/app.DV) ~= floor(app.xcr(3, :)/app.DV) |...
                floor(app.xcr(3, :)/app.DV) ~= floor(app.xcr(4, :)/app.DV) | floor(app.xcr(4, :)/app.DV) ~= floor(app.xcr(1, :)/app.DV));
            
            total_consequtive = 0;
            total_consequtive = total_consequtive + sum((floor(app.xcr(2, :)/app.DV) ~= floor(app.xcr(3, :)/app.DV)) & (floor(app.xcr(3, :)/app.DV) ~= floor(app.xcr(4, :)/app.DV))) + ...
                sum((floor(app.xcr(4, :)/app.DV) ~= floor(app.xcr(1, :)/app.DV)) & (floor(app.xcr(1, :)/app.DV) ~= floor(app.xcr(2, :)/app.DV)));
            
            total_con_over_int = total_consequtive/total_intersected;
			
			rt_estimate = 2 - total_con_over_int;
			UIUpdateOutEstimate(app, ['Sqrt(2) Estimate: ' num2str(rt_estimate)]);
		end
		
		function UIUpdateOutEstimate(app, value)
			set(app.OutEstimateLabel, 'Text', value);
        end
        
        function UIDoClearAxes(app)
			cla(app.UIAxes, 'reset');
			axis(app.UIAxes, [0 1.0 0 1.0]);
        end
        
        function UIUpdateCurrentTask(app, newTaskNo)
            set(app.NHorizontalTilesSlider, 'Visible', false);
            set(app.NHorizontalTilesSliderLabel, 'Visible', false);
            set(app.roottwoButton, 'Enable', false);
            set(app.NeedlesButton, 'Enable', false);
            
            if newTaskNo == 1
                set(app.NumberoffloorplanksSliderLabel, 'Text', 'Number of floor planks...');
            end
            
            if newTaskNo == 2
                set(app.roottwoButton, 'Enable', true);
                set(app.NumberoffloorplanksSliderLabel, 'Text', 'Number of floor planks...');
            end
            
            if newTaskNo == 3
                set(app.NeedlesButton, 'Enable', true);
                set(app.NHorizontalTilesSlider, 'Visible', true);
                set(app.NHorizontalTilesSliderLabel, 'Visible', true);
                
                set(app.NumberoffloorplanksSliderLabel, 'Text', 'M (Verticle tiles)');
            end
            
            app.currentTask = newTaskNo;
			beginEstimation(app);
        end
		
        function UIUpdateEstimationItem(app, item)
            spinnerText = 'Number of Squares...';
            lengthText = 'Length of Square sides...';
            
            if strcmp(item, 'Needles')
                spinnerText = 'Number of Needles...';
                lengthText = 'Length of Needle sides...';
            end
            
            set(app.NumberofsquaresSpinnerLabel, 'Text', spinnerText);
            set(app.LengthofsquaresidesSliderLabel, 'Text', lengthText);
        end
        
        function UIChangeNeedleSelections(app, selected)
            set(app.nSpinner, 'Visible', false);
            set(app.nSpinnerLabel, 'Visible', false);
            
            switch selected
                case 'Highlight closest'
                    set(app.nSpinner, 'Visible', true);
                    set(app.nSpinnerLabel, 'Visible', true);
                case 'Do nothing'
                    disp('');
                case 'Highlight similar angles'
                    disp('');
            end
        end
		
		function LineSelected(app, src, evt)
            if ~isempty(app.lastClickedLine)
			    set(app.lastClickedLine, 'Color', app.lastClickedLineColor);
            end
            
            app.lastClickedLineColor = get(src, 'Color');
            app.lastClickedLine = src;
			set(src, 'Color', app.uiSelectedPolyColor);
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
            app.gridlinesH
            app.gridlinesV
		end
	end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
			app.DV	=	app.S / app.NoVP;
			app.DH	=	app.S / app.NoVP;
			app.SL	=	app.DV / 2;
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
			set(app.PlottingStatusLamp, 'Color', '#f00');
			beginEstimation(app);
			set(app.PlottingStatusLamp, 'Color', '#0f0');
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
            c = uisetcolor([0 0 0], 'Change intersecting shape colour');
			set(app.CurrentShapeColourIntersect, 'Color', c);
            
            app.uiIntersectPolyColor = c;
        end

        % Button pushed function: 
        % ModifyShapeColourNonIntersectButton
        function ModifyShapeColourNonIntersectButtonPushed(app, event)
            c = uisetcolor([0 0 0], 'Change non-intersecting shape colour');
			set(app.CurrentShapeColourNonIntersect, 'Color', c);
            
            app.uiNonIntersectPolyColor = c;
        end

        % Button pushed function: ModifyShapeColourSelectedButton
        function ModifyShapeColourSelectedButtonPushed(app, event)
            c = uisetcolor([0 0 0], 'Change selected needle colour');
			set(app.CurrentShapeColourSelected, 'Color', c);
            
            app.uiSelectedPolyColor = c;
        end

        % Button pushed function: ModifyShapeColourSimilarButton
        function ModifyShapeColourSimilarButtonPushed(app, event)
            c = uisetcolor([0 0 0], 'Change selected needle colour');
			set(app.CurrentShapeColourSelected, 'Color', c);
            
            app.uiSimilarPolyColor = c;
        end

        % Selection changed function: 
        % SelectedNeedleControlsButtonGroup
        function SelectedNeedleControlsButtonGroupSelectionChanged(app, event)
            selectedButton = app.SelectedNeedleControlsButtonGroup.SelectedObject;
            
            UIChangeNeedleSelections(app, selectedButton.Text);
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

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 301 518];

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
            app.NumberofitemSpinner.Value = 1000;

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

            % Create PlottingStatusLampLabel
            app.PlottingStatusLampLabel = uilabel(app.PlotControlsTab);
            app.PlottingStatusLampLabel.HorizontalAlignment = 'right';
            app.PlottingStatusLampLabel.Position = [174 215 83 22];
            app.PlottingStatusLampLabel.Text = 'Plotting Status';

            % Create PlottingStatusLamp
            app.PlottingStatusLamp = uilamp(app.PlotControlsTab);
            app.PlottingStatusLamp.Position = [266 216 20 20];

            % Create LengthofsquaresidesSliderLabel
            app.LengthofsquaresidesSliderLabel = uilabel(app.PlotControlsTab);
            app.LengthofsquaresidesSliderLabel.HorizontalAlignment = 'right';
            app.LengthofsquaresidesSliderLabel.Position = [6 166 130 22];
            app.LengthofsquaresidesSliderLabel.Text = 'Length of square sides:';

            % Create LengthofitemsidesSlider
            app.LengthofitemsidesSlider = uislider(app.PlotControlsTab);
            app.LengthofitemsidesSlider.Limits = [1 10];
            app.LengthofitemsidesSlider.MajorTicks = [1 2 3 4 5 6 7 8 9 10];
            app.LengthofitemsidesSlider.MajorTickLabels = {'0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1.0'};
            app.LengthofitemsidesSlider.ValueChangedFcn = createCallbackFcn(app, @LengthofitemsidesSliderValueChanged, true);
            app.LengthofitemsidesSlider.MinorTicks = [];
            app.LengthofitemsidesSlider.Position = [15 155 267 7];
            app.LengthofitemsidesSlider.Value = 1;

            % Create WarningSquarelengthPlankdistanceLabel
            app.WarningSquarelengthPlankdistanceLabel = uilabel(app.PlotControlsTab);
            app.WarningSquarelengthPlankdistanceLabel.FontColor = [1 0 0];
            app.WarningSquarelengthPlankdistanceLabel.Visible = 'off';
            app.WarningSquarelengthPlankdistanceLabel.Position = [25 187 228 22];
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
            app.ButtonTask1.Position = [13 5 54 22];
            app.ButtonTask1.Value = true;

            % Create ButtonTask2
            app.ButtonTask2 = uitogglebutton(app.SelectTaskButtonGroup);
            app.ButtonTask2.Text = '2';
            app.ButtonTask2.Position = [103 5 49 22];

            % Create ButtonTask3
            app.ButtonTask3 = uitogglebutton(app.SelectTaskButtonGroup);
            app.ButtonTask3.Text = '3';
            app.ButtonTask3.Position = [190 5 51 22];

            % Create SelectedNeedleControlsButtonGroup
            app.SelectedNeedleControlsButtonGroup = uibuttongroup(app.PlotControlsTab);
            app.SelectedNeedleControlsButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @SelectedNeedleControlsButtonGroupSelectionChanged, true);
            app.SelectedNeedleControlsButtonGroup.Title = 'Selected Needle Controls';
            app.SelectedNeedleControlsButtonGroup.Position = [7 3 157 106];

            % Create DonothingButton
            app.DonothingButton = uitogglebutton(app.SelectedNeedleControlsButtonGroup);
            app.DonothingButton.Text = 'Do nothing';
            app.DonothingButton.Position = [9 55 138 22];
            app.DonothingButton.Value = true;

            % Create HighlightclosestButton
            app.HighlightclosestButton = uitogglebutton(app.SelectedNeedleControlsButtonGroup);
            app.HighlightclosestButton.Text = 'Highlight closest';
            app.HighlightclosestButton.Position = [9 32 137 22];

            % Create HighlightsimilaranglesButton
            app.HighlightsimilaranglesButton = uitogglebutton(app.SelectedNeedleControlsButtonGroup);
            app.HighlightsimilaranglesButton.Text = 'Highlight similar angles';
            app.HighlightsimilaranglesButton.Position = [9 9 137 22];

            % Create nSpinnerLabel
            app.nSpinnerLabel = uilabel(app.PlotControlsTab);
            app.nSpinnerLabel.HorizontalAlignment = 'right';
            app.nSpinnerLabel.Visible = 'off';
            app.nSpinnerLabel.Position = [196 87 25 22];
            app.nSpinnerLabel.Text = 'n';

            % Create nSpinner
            app.nSpinner = uispinner(app.PlotControlsTab);
            app.nSpinner.Visible = 'off';
            app.nSpinner.Position = [236 87 43 22];

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
            app.ModifyShapeColourNonIntersectButton.Position = [47 336 229 22];
            app.ModifyShapeColourNonIntersectButton.Text = 'Modify Non-intersecting Polygon Colour';

            % Create CurrentShapeColourNonIntersect
            app.CurrentShapeColourNonIntersect = uilamp(app.FigureTab);
            app.CurrentShapeColourNonIntersect.Position = [16 335 25 25];
            app.CurrentShapeColourNonIntersect.Color = [1 0 0];

            % Create ModifyShapeColourIntersectButton
            app.ModifyShapeColourIntersectButton = uibutton(app.FigureTab, 'push');
            app.ModifyShapeColourIntersectButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyShapeColourIntersectButtonPushed, true);
            app.ModifyShapeColourIntersectButton.Position = [60 370 204 22];
            app.ModifyShapeColourIntersectButton.Text = 'Modify Intersecting Polygon Colour';

            % Create CurrentShapeColourIntersect
            app.CurrentShapeColourIntersect = uilamp(app.FigureTab);
            app.CurrentShapeColourIntersect.Position = [15 370 25 25];

            % Create ModifyGridLineColourButton
            app.ModifyGridLineColourButton = uibutton(app.FigureTab, 'push');
            app.ModifyGridLineColourButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyGridLineColourButtonPushed, true);
            app.ModifyGridLineColourButton.Position = [92 404 142 22];
            app.ModifyGridLineColourButton.Text = 'Modify Grid Line Colour';

            % Create CurrentGridLineColour
            app.CurrentGridLineColour = uilamp(app.FigureTab);
            app.CurrentGridLineColour.Position = [15 403 25 25];
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
            app.ModifyShapeColourSelectedButton.Position = [72 302 181 22];
            app.ModifyShapeColourSelectedButton.Text = 'Modify Selected Needle Colour';

            % Create CurrentShapeColourSelected
            app.CurrentShapeColourSelected = uilamp(app.FigureTab);
            app.CurrentShapeColourSelected.Position = [16 301 25 25];
            app.CurrentShapeColourSelected.Color = [0 0 1];

            % Create ModifyShapeColourSimilarButton
            app.ModifyShapeColourSimilarButton = uibutton(app.FigureTab, 'push');
            app.ModifyShapeColourSimilarButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyShapeColourSimilarButtonPushed, true);
            app.ModifyShapeColourSimilarButton.Position = [72 271 181 22];
            app.ModifyShapeColourSimilarButton.Text = 'Modify Similar Needle Colour';

            % Create CurrentShapeColourSimilar
            app.CurrentShapeColourSimilar = uilamp(app.FigureTab);
            app.CurrentShapeColourSimilar.Position = [16 270 25 25];
            app.CurrentShapeColourSimilar.Color = [0.7216 0.2706 1];

            % Create OutEstimateLabel
            app.OutEstimateLabel = uilabel(app.UIFigure);
            app.OutEstimateLabel.FontSize = 16;
            app.OutEstimateLabel.Position = [307 29 309 22];
            app.OutEstimateLabel.Text = 'Pi Estimate: N/A';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Floor')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.UIAxes.Position = [301 50 540 469];

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
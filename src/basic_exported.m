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
        NumberofsquaresSpinner          matlab.ui.control.Spinner
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
        LengthofsquaresidesSlider       matlab.ui.control.Slider
        WarningSquarelengthPlankdistanceLabel  matlab.ui.control.Label
        NumberofhorizontalplanksSliderLabel  matlab.ui.control.Label
        NumberofhorizontalplanksSlider  matlab.ui.control.Slider
        SelectTaskButtonGroup           matlab.ui.container.ButtonGroup
        Button                          matlab.ui.control.ToggleButton
        Button_2                        matlab.ui.control.ToggleButton
        Button_3                        matlab.ui.control.ToggleButton
        UIControlsTab                   matlab.ui.container.Tab
        FontSizeSliderLabel             matlab.ui.control.Label
        FontSizeSlider                  matlab.ui.control.Slider
        ModifyFontColourButton          matlab.ui.control.Button
        CurrentLampLabel                matlab.ui.control.Label
        CurrentFontColorLamp            matlab.ui.control.Lamp
        ModifyhowtheestimateisdisplayedLabel  matlab.ui.control.Label
        GridLineThicknessSpinnerLabel   matlab.ui.control.Label
        GridLineThicknessSpinner        matlab.ui.control.Spinner
        ModifyGridLineColorButton       matlab.ui.control.Button
        CurrentLampLabel_2              matlab.ui.control.Label
        CurrentFontColorLamp_2          matlab.ui.control.Lamp
        ModifySquareColourButton_2      matlab.ui.control.Button
        CurrentLampLabel_3              matlab.ui.control.Label
        CurrentFontColorLamp_3          matlab.ui.control.Lamp
        SwitchLabel                     matlab.ui.control.Label
        AutomaticallyrerunsimulationwhenanimportantvaluechangesSwitch  matlab.ui.control.Switch
        c1931370Label                   matlab.ui.control.Label
        OutEstimateLabel                matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
		calc    =   1                   % What are we calculating? 1 = pi, 2 = sqrt(2)
        S	    =	1					% Scale factor
        N	    =	2000			    % Number of shapes
		NoVP	=	5				    % Number of planks
        NoHP    =   5                   % Number of horizontal planks
		DV							    % Distance between vertical planks
		DH							    % Distance between horizontal planks
		SL							    % Length of shape
        
        % Custom variables
        uiGridlineWidth =   1
		
		% Patch object
		p
		
		% State
		sq_angles
		xc
		yc
		xcr
		ycr
    end
    
    methods (Access = private)
        
		function beginEstimation(app)
			updateSquarePlot(app);
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
			
            set(app.UsegridSwitch, 'Value', 'On');
            
			beginEstimation(app);
        end
        
        function makeWarningForLgtD(app)
            if app.SL > app.DV
                set(app.WarningSquarelengthPlankdistanceLabel, 'Visible', true);
            else
                set(app.WarningSquarelengthPlankdistanceLabel, 'Visible', false);
            end
        end
        
		function updateItemCount(app, squareCount)
			app.N = squareCount;
			beginEstimation(app);
		end
        
        function updateItemLength(app, itemLength)
			app.SL = itemLength;
            makeWarningForLgtD(app);
			beginEstimation(app);
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
			updatePlotGrid(app);
			
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
			
			app.p = patch(app.UIAxes, app.xcr, app.ycr, 'red');
		end
		
		function calculateSquarePi(app)
			n = 0;
			n = n + sum(floor(app.xcr(1, :)/app.DV) ~= floor(app.xcr(2, :)/app.DV)) + ...
					sum(floor(app.xcr(2, :)/app.DV) ~= floor(app.xcr(3, :)/app.DV)) + ...
					sum(floor(app.xcr(3, :)/app.DV) ~= floor(app.xcr(4, :)/app.DV)) + ...
					sum(floor(app.xcr(4, :)/app.DV) ~= floor(app.xcr(1, :)/app.DV));
            
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
		
		function updatePlotFloor(app)
			for i = 0:app.DV:app.S
				xline(app.UIAxes, i,  '-', 'LineWidth', app.uiGridlineWidth);
			end
		end
		
		function updatePlotGrid(app)
			for i = 0:app.DH:app.S
				yline(app.UIAxes, i,  '-', 'LineWidth', app.uiGridlineWidth);
			end
		end
	end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
			app.DV	=	app.S / app.NoVP;
			app.SL	=	app.DV / 2;
        end

        % Value changed function: NumberofsquaresSpinner
        function NumberofsquaresSpinnerValueChanged(app, event)
            value = ceil(app.NumberofsquaresSpinner.Value);
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

        % Value changed function: LengthofsquaresidesSlider
        function LengthofsquaresidesSliderValueChanged(app, event)
            value = app.LengthofsquaresidesSlider.Value;
            
            [~, minVal] = min(abs(value - event.Source.MajorTicks(:)));
			event.Source.Value = event.Source.MajorTicks(minVal);
            
			updateItemLength(app, minVal / 10);
        end

        % Button pushed function: ModifyGridLineColorButton
        function ModifyGridLineColorButtonPushed(app, event)
            c = uisetcolor([0 0 0], 'Change grid line colour');
            
            set(app.OutEstimateLabel, 'FontColor', c);
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

        % Value changed function: NumberofhorizontalplanksSlider
        function NumberofhorizontalplanksSliderValueChanged(app, event)
            value = app.NumberofhorizontalplanksSlider.Value;
            
            % Snap to nearest value
            [~, minVal] = min(abs(value - event.Source.MajorTicks(:)));
			event.Source.Value = event.Source.MajorTicks(minVal);
            
            updateHorizontalPlankCount(app, minVal);
        end

        % Value changed function: GridLineThicknessSpinner
        function GridLineThicknessSpinnerValueChanged(app, event)
            value = app.GridLineThicknessSpinner.Value;
            app.uiGridlineWidth = value;
            
            beginEstimation(app);
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
            app.EstimatevalueusingButtonGroup.Title = 'Estimate value using...';
            app.EstimatevalueusingButtonGroup.Position = [152 333 147 95];

            % Create SquaresButton
            app.SquaresButton = uiradiobutton(app.EstimatevalueusingButtonGroup);
            app.SquaresButton.Text = 'Squares';
            app.SquaresButton.Position = [11 49 67 22];
            app.SquaresButton.Value = true;

            % Create NeedlesButton
            app.NeedlesButton = uiradiobutton(app.EstimatevalueusingButtonGroup);
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

            % Create NumberofsquaresSpinner
            app.NumberofsquaresSpinner = uispinner(app.PlotControlsTab);
            app.NumberofsquaresSpinner.Limits = [1 10000000];
            app.NumberofsquaresSpinner.ValueChangedFcn = createCallbackFcn(app, @NumberofsquaresSpinnerValueChanged, true);
            app.NumberofsquaresSpinner.HorizontalAlignment = 'left';
            app.NumberofsquaresSpinner.Position = [156 282 142 22];
            app.NumberofsquaresSpinner.Value = 1000;

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
            app.EstimateButton.Position = [97 49 100 29];
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

            % Create LengthofsquaresidesSlider
            app.LengthofsquaresidesSlider = uislider(app.PlotControlsTab);
            app.LengthofsquaresidesSlider.Limits = [1 10];
            app.LengthofsquaresidesSlider.MajorTicks = [1 2 3 4 5 6 7 8 9 10];
            app.LengthofsquaresidesSlider.MajorTickLabels = {'0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1.0'};
            app.LengthofsquaresidesSlider.ValueChangedFcn = createCallbackFcn(app, @LengthofsquaresidesSliderValueChanged, true);
            app.LengthofsquaresidesSlider.MinorTicks = [];
            app.LengthofsquaresidesSlider.Position = [15 155 267 7];
            app.LengthofsquaresidesSlider.Value = 1;

            % Create WarningSquarelengthPlankdistanceLabel
            app.WarningSquarelengthPlankdistanceLabel = uilabel(app.PlotControlsTab);
            app.WarningSquarelengthPlankdistanceLabel.FontColor = [1 0 0];
            app.WarningSquarelengthPlankdistanceLabel.Visible = 'off';
            app.WarningSquarelengthPlankdistanceLabel.Position = [38 87 228 22];
            app.WarningSquarelengthPlankdistanceLabel.Text = 'Warning! Square length > Plank distance ';

            % Create NumberofhorizontalplanksSliderLabel
            app.NumberofhorizontalplanksSliderLabel = uilabel(app.PlotControlsTab);
            app.NumberofhorizontalplanksSliderLabel.HorizontalAlignment = 'right';
            app.NumberofhorizontalplanksSliderLabel.Position = [3 236 155 22];
            app.NumberofhorizontalplanksSliderLabel.Text = 'Number of horizontal planks';

            % Create NumberofhorizontalplanksSlider
            app.NumberofhorizontalplanksSlider = uislider(app.PlotControlsTab);
            app.NumberofhorizontalplanksSlider.Limits = [1 10];
            app.NumberofhorizontalplanksSlider.MajorTicks = [1 2 3 4 5 6 7 8 9 10];
            app.NumberofhorizontalplanksSlider.MajorTickLabels = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};
            app.NumberofhorizontalplanksSlider.ValueChangedFcn = createCallbackFcn(app, @NumberofhorizontalplanksSliderValueChanged, true);
            app.NumberofhorizontalplanksSlider.MinorTicks = [];
            app.NumberofhorizontalplanksSlider.Position = [10 225 135 7];
            app.NumberofhorizontalplanksSlider.Value = 5;

            % Create SelectTaskButtonGroup
            app.SelectTaskButtonGroup = uibuttongroup(app.PlotControlsTab);
            app.SelectTaskButtonGroup.Title = 'Select Task';
            app.SelectTaskButtonGroup.Position = [23 433 255 50];

            % Create Button
            app.Button = uitogglebutton(app.SelectTaskButtonGroup);
            app.Button.Text = '1';
            app.Button.Position = [13 5 54 22];
            app.Button.Value = true;

            % Create Button_2
            app.Button_2 = uitogglebutton(app.SelectTaskButtonGroup);
            app.Button_2.Text = '2';
            app.Button_2.Position = [103 5 49 22];

            % Create Button_3
            app.Button_3 = uitogglebutton(app.SelectTaskButtonGroup);
            app.Button_3.Text = '3';
            app.Button_3.Position = [190 5 51 22];

            % Create UIControlsTab
            app.UIControlsTab = uitab(app.TabGroup);
            app.UIControlsTab.Title = 'UI Controls';

            % Create FontSizeSliderLabel
            app.FontSizeSliderLabel = uilabel(app.UIControlsTab);
            app.FontSizeSliderLabel.HorizontalAlignment = 'right';
            app.FontSizeSliderLabel.Position = [47 428 56 22];
            app.FontSizeSliderLabel.Text = 'Font Size';

            % Create FontSizeSlider
            app.FontSizeSlider = uislider(app.UIControlsTab);
            app.FontSizeSlider.Limits = [12 20];
            app.FontSizeSlider.MajorTicks = [12 14 16 18 20];
            app.FontSizeSlider.MajorTickLabels = {'XS', 'S', 'M', 'L', 'XL'};
            app.FontSizeSlider.ValueChangedFcn = createCallbackFcn(app, @FontSizeSliderValueChanged, true);
            app.FontSizeSlider.MinorTicks = [];
            app.FontSizeSlider.Position = [19 418 112 7];
            app.FontSizeSlider.Value = 14;

            % Create ModifyFontColourButton
            app.ModifyFontColourButton = uibutton(app.UIControlsTab, 'push');
            app.ModifyFontColourButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyFontColourButtonPushed, true);
            app.ModifyFontColourButton.Position = [11 347 137 22];
            app.ModifyFontColourButton.Text = 'Modify Font Colour';

            % Create CurrentLampLabel
            app.CurrentLampLabel = uilabel(app.UIControlsTab);
            app.CurrentLampLabel.HorizontalAlignment = 'right';
            app.CurrentLampLabel.Position = [166 346 48 22];
            app.CurrentLampLabel.Text = 'Current:';

            % Create CurrentFontColorLamp
            app.CurrentFontColorLamp = uilamp(app.UIControlsTab);
            app.CurrentFontColorLamp.Position = [224 346 25 25];
            app.CurrentFontColorLamp.Color = [0 0 0];

            % Create ModifyhowtheestimateisdisplayedLabel
            app.ModifyhowtheestimateisdisplayedLabel = uilabel(app.UIControlsTab);
            app.ModifyhowtheestimateisdisplayedLabel.Position = [8 456 201 22];
            app.ModifyhowtheestimateisdisplayedLabel.Text = 'Modify how the estimate is displayed';

            % Create GridLineThicknessSpinnerLabel
            app.GridLineThicknessSpinnerLabel = uilabel(app.UIControlsTab);
            app.GridLineThicknessSpinnerLabel.HorizontalAlignment = 'right';
            app.GridLineThicknessSpinnerLabel.Position = [16 283 111 22];
            app.GridLineThicknessSpinnerLabel.Text = 'Grid Line Thickness';

            % Create GridLineThicknessSpinner
            app.GridLineThicknessSpinner = uispinner(app.UIControlsTab);
            app.GridLineThicknessSpinner.Limits = [1 5];
            app.GridLineThicknessSpinner.ValueChangedFcn = createCallbackFcn(app, @GridLineThicknessSpinnerValueChanged, true);
            app.GridLineThicknessSpinner.Position = [142 283 100 22];
            app.GridLineThicknessSpinner.Value = 1;

            % Create ModifyGridLineColorButton
            app.ModifyGridLineColorButton = uibutton(app.UIControlsTab, 'push');
            app.ModifyGridLineColorButton.ButtonPushedFcn = createCallbackFcn(app, @ModifyGridLineColorButtonPushed, true);
            app.ModifyGridLineColorButton.Position = [15 236 137 22];
            app.ModifyGridLineColorButton.Text = 'Modify Grid Line Color';

            % Create CurrentLampLabel_2
            app.CurrentLampLabel_2 = uilabel(app.UIControlsTab);
            app.CurrentLampLabel_2.HorizontalAlignment = 'right';
            app.CurrentLampLabel_2.Position = [168 236 48 22];
            app.CurrentLampLabel_2.Text = 'Current:';

            % Create CurrentFontColorLamp_2
            app.CurrentFontColorLamp_2 = uilamp(app.UIControlsTab);
            app.CurrentFontColorLamp_2.Position = [224 235 25 25];
            app.CurrentFontColorLamp_2.Color = [0 0 0];

            % Create ModifySquareColourButton_2
            app.ModifySquareColourButton_2 = uibutton(app.UIControlsTab, 'push');
            app.ModifySquareColourButton_2.Position = [16 195 137 22];
            app.ModifySquareColourButton_2.Text = 'Modify Square Colour';

            % Create CurrentLampLabel_3
            app.CurrentLampLabel_3 = uilabel(app.UIControlsTab);
            app.CurrentLampLabel_3.HorizontalAlignment = 'right';
            app.CurrentLampLabel_3.Position = [167 194 48 22];
            app.CurrentLampLabel_3.Text = 'Current:';

            % Create CurrentFontColorLamp_3
            app.CurrentFontColorLamp_3 = uilamp(app.UIControlsTab);
            app.CurrentFontColorLamp_3.Position = [225 194 25 25];
            app.CurrentFontColorLamp_3.Color = [0 0 0];

            % Create SwitchLabel
            app.SwitchLabel = uilabel(app.UIControlsTab);
            app.SwitchLabel.HorizontalAlignment = 'center';
            app.SwitchLabel.WordWrap = 'on';
            app.SwitchLabel.Position = [82 136 194 50];
            app.SwitchLabel.Text = 'Automatically re-run simulation when an important value changes';

            % Create AutomaticallyrerunsimulationwhenanimportantvaluechangesSwitch
            app.AutomaticallyrerunsimulationwhenanimportantvaluechangesSwitch = uiswitch(app.UIControlsTab, 'slider');
            app.AutomaticallyrerunsimulationwhenanimportantvaluechangesSwitch.Position = [40 156 23 10];

            % Create c1931370Label
            app.c1931370Label = uilabel(app.UIFigure);
            app.c1931370Label.Position = [750 504 54 15];
            app.c1931370Label.Text = 'c1931370';

            % Create OutEstimateLabel
            app.OutEstimateLabel = uilabel(app.UIFigure);
            app.OutEstimateLabel.FontSize = 16;
            app.OutEstimateLabel.Position = [307 29 228 22];
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
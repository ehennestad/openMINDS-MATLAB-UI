classdef IntroPage < wizard.abstract.Page


    properties (Constant)
        Name = "Intro"
        Title = "Welcome"
        Description = [...
            "This dialog will guide you through the initialization of an openMINDS research product\n\n" + ...
            "The aims are:\n" + ...
            "  1. Select research product\n" + ...
            "  2. Initialize metadata collection\n" + ...
            "  3. Add metadata" ]

    end

    properties (Access = private) % App components
        GridLayout
        StartButton
    end
    
    methods
        function obj = IntroPage()
            obj.ShowNavigationButtons = false;
            obj.DoCreatePanel = true;
        end
    end

    methods (Access = protected)
        function onPageEntered(obj)
            % Subclasses may override
            obj.ParentApp.DescriptionLabel.Layout.Row = [1,2];
        end

        function onPageExited(obj)
            % Subclasses may override
            obj.ParentApp.DescriptionLabel.Layout.Row = [1];
        end

        function createComponents(obj)
            obj.UIPanel.BorderType = 'none';

            obj.GridLayout = uigridlayout(obj.UIPanel);
            obj.GridLayout.ColumnWidth = {'1x', 150, '1x'};
            obj.GridLayout.RowHeight = {'2x', 50, '1x'};
            obj.GridLayout.Padding = 0;
            %obj.GridLayout.Layout.Row = 3;
            %obj.GridLayout.Layout.Column = 1;
            obj.GridLayout.BackgroundColor = obj.ParentApp.BodyGridLayout.BackgroundColor;

            obj.StartButton = uibutton( obj.GridLayout, 'push' );
            obj.StartButton.Layout.Row = 2;
            obj.StartButton.Layout.Column = 2;
            obj.StartButton.ButtonPushedFcn = @(s,e) obj.changePage;

            obj.StartButton.BackgroundColor = om.wizard.WizardTheme.DarkPrimaryColor;
            obj.StartButton.FontColor = "white";
            obj.StartButton.FontSize = 16;
            obj.StartButton.Text = "Get Started";

        end

        function changePage(obj)
            obj.ParentApp.changeWizardPage([], 2)
        end
    end


end
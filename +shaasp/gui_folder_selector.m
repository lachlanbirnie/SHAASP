function [fold_paths] = gui_folder_selector(prompts, default_paths)
% GUI_FOLDER_SELECTOR - GUI to select multiple folder paths in finder.
%
% Syntax:  [file_paths] = folderSelectorGUI(prompts, default_paths)
%
% Inputs:
%
%   prompts - [N by 1] array of strings to guide user folders to select.
%           -- N defines the number of GUI buttons.
%
%   default_paths - [N by 1] array of path strings to default the finder
%                   location for each button.
%
% Outputs:
%
%   fold_paths - [N by 1] Cell Array of path strings for each folder
%                selected.
%              -- Returns a single String if N is 1.
%
% Example: 
%   
%   [fold_paths] = folderSelectorGUI(["recording folder", "reference folder"]);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: fileSelectorGUI
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 29-May-2024
% Last revision: 19-July-2024

    % Handle inputs.
    num_files = numel(prompts);

    if (nargin < 2)
        default_paths = [];
    end

    % Define outputs.
    fold_paths = cell(1, num_files);

    % Constants.
    font_size = 12;

    % UI layout by number of files (i).
    ext_height = 0.1;  % Finish btn height.

    btn_height = (1 - ext_height) / num_files;
    btn_width = 0.3;
    btn_border = 0.02;

    btn_x = @(i) 0 + btn_border;
    btn_y = @(i) 0 + btn_height * (i-1) + btn_border;
    btn_w = @(i) btn_width - 2 * btn_border;
    btn_h = @(i) btn_height - 2 * btn_border;

    txt_width = 1 - btn_width;
    txt_height = btn_height;
    txt_border = 2 * btn_border;

    txt_x = @(i) btn_width + txt_border;
    txt_y = @(i) btn_y(i) - btn_border + txt_border;
    txt_w = @(i) txt_width - 2 * txt_border;
    txt_h = @(i) txt_height - 2 * txt_border;

    ext_x = btn_x(1);
    ext_y = btn_y(num_files) + btn_h(1) + 2*btn_border;
    ext_w = btn_w(1);
    ext_h = ext_height - 2 * btn_border;

    % Create GUI.
    fig = figure('Name', 'Select Files', ...
        'Units', 'normalized', ...
        'Color', [1, 1, 1], ...
        'Position', [0.1, 0.1, 0.8, 0.8]);

    % Finished button.
    uicontrol('Style', 'pushbutton', ...
        'String', 'Finished Selection', ...
        'FontSize', font_size, ...
        'BackgroundColor', [0.6, 1, 0.6], ...
        'Units', 'normalized', ...
        'Position', [ext_x, ext_y, ext_w, ext_h], ...
        'Callback', @finishSelection);

    uicontrol('Style', 'text', ...
        'String', 'Select the files to be processed', ...
        'FontSize', 2*font_size, ...
        'BackgroundColor', [1, 1, 1], ...
        'HorizontalAlignment', 'left', ...
        'Units', 'normalized', ...
        'Position', [txt_x(1), ext_y, txt_w(1), ext_h]);

    % File select button and text.
    Btn = cell([]);
    Txt = cell([]);

    for i = 1:num_files
        Btn{i} = uicontrol('Style', 'pushbutton', ...
            'String', prompts(i), ...
            'FontSize', font_size, ...
            'Units', 'normalized', ...
            'Position', [btn_x(i), btn_y(i), btn_w(i), btn_h(i)], ...
            'UserData', i, ...
            'Callback', @selectFolder);

        Txt{i} = uicontrol('Style', 'text', ...
            'String', 'Push button to select file.', ...
            'FontSize', font_size, ...
            'BackgroundColor', [1, 1, 1], ...
            'HorizontalAlignment', 'left', ...
            'Units', 'normalized', ...
            'Position', [txt_x(i), txt_y(i), txt_w(i), txt_h(i)]);
    end

    % Pre-load default paths if provided.
    if ~isempty(default_paths)
        num_defaults = min(numel(default_paths), num_files);
        for i = 1:num_defaults
            fold_paths{i} = default_paths(i);
            set(Txt{i}, 'String', ['Selected Default: ', default_paths(i)]);
        end
    end

    % Needed to wait for user to select files before returning value.
    uiwait(fig);

    % Callback to select file.
    function selectFolder(src, ~)
        prompt = get(src, 'String');
        ind = get(src, 'UserData');
        fold_path = uigetdir('.', prompt);
        if fold_path ~= 0
            fold_paths{ind} = fold_path;
            set(Txt{ind}, 'String', ['Selected: ', fold_path]);
        end
    end

    % Callback to finish file selection.
    function finishSelection(~, ~)
        if isscalar(fold_paths)
            fold_paths = fold_paths{1};
        end
        close(fig);
    end

end
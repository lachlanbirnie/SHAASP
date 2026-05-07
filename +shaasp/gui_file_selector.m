function [file_paths] = gui_file_selector(prompts, default_paths)
% GUI_FILE_SELECTOR - GUI to select multiple file paths in finder.
%
% Syntax:  [file_paths] = fileSelectorGUI(prompts, default_paths)
%
% Inputs:
%
%   prompts - [N by 1] array of strings to guide user what files to load.
%           -- N defines the number of GUI buttons.
%
%   default_paths - [N by 1] array of path strings to default the finder
%                   location for each button.
%
% Outputs:
%
%   file_paths - [N by 1] Cell Array of path strings for each file
%                selected.
%              -- Returns a single String if N is 1.
%
% Example: 
%   
%   [file_paths] = fileSelectorGUI(["recording", "reference"]);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: folderSelectorGUI
%
% Author: Lachlan Birnie
% Audio & Acoustic Signal Processing Group - Australian National University
% Email: Lachlan.Birnie@anu.edu.au
% Website: https://github.com/lachlanbirnie
% Creation: 29-May-2024
% Last revision: 24-July-2024

    % Handle inputs.
    num_files = numel(prompts);

    if (nargin < 2)
        default_paths = [];
    end

    % Define outputs.
    file_paths = cell(1, num_files);

    % Constants.
    font_size = 12;

    % UI layout by number of files (i).
    ext_height = 0.1;  % Finish btn height.

    btn_height = (1 - ext_height) / num_files;
    btn_width = 0.3;
    btn_border = 0.02;

    btn_x = @(i) 0 + btn_border;
    btn_y = @(i) 0 + btn_height * (num_files - i) + btn_border;
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
    ext_y = btn_y(1) + btn_h(1) + 2*btn_border;
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
            'Callback', @selectFile);

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
            file_paths{i} = default_paths(i);
            set(Txt{i}, 'String', ['Selected Default: ', default_paths(i)]);
        end
    end

    % Needed to wait for user to select files before returning value.
    uiwait(fig);

    % Callback to select file.
    function selectFile(src, ~)
        prompt = get(src, 'String');
        ind = get(src, 'UserData');
        [fname, fpath] = uigetfile('*.*', prompt);
        if fname ~= 0
            file_path = fullfile(fpath, fname);
            file_paths{ind} = file_path;
            set(Txt{ind}, 'String', ['Selected: ', file_path]);
        end
    end

    % Callback to finish file selection.
    function finishSelection(~, ~)
        if isscalar(file_paths)
            file_paths = file_paths{1};
        end
        close(fig);
    end

end
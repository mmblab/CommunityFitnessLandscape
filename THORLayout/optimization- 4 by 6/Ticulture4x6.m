%% Triculture 4x6 - Optimization of concentrations
%   This script reads an excel document with the data for a triangle array
%   pattern with corner ROIs and processes the data.
%   Conditions:
%   -   The first group of triangle must be the control
%   -   The next three must have the same combinations, three different
%       combinations in the same group of six, each combination across from
%       its match
%   -   There should be 96 data points, 24 triangle means and 72 corner
%       means

function data = Triculture4x6()
    [table, cwd] = importTable('Please select the data you wish to load', pwd);
    
    

end

function newTable = reorderTable(orig)
    %REORDERTABLE organizes the data from the format seen in the excel
    %   sheet and tags the combinations.
    newTable = table();
end

function [table, filepath] = importTable(prompt,filepath)
    %IMPORTABLE Takes a string prompt, and returns the table. The
    %   filepath is returned to make the next file save easier
    disp(prompt);
    pause(3);

    % Opens the UI file explorer at filepath the most recently used
    %   filepath
    [filename, filepath] = uigetfile('*.*','',filepath); 
    table = readtable(strcat(filepath,filename));
end
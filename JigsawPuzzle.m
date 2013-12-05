%% JIGSAWPUZZLE MATLAB code for JigsawPuzzle.fig
function varargout = JigsawPuzzle(varargin)
     % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @JigsawPuzzle_OpeningFcn, ...
                       'gui_OutputFcn',  @JigsawPuzzle_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end

% --- Executes just before JigsawPuzzle is made visible.
function JigsawPuzzle_OpeningFcn(hObject, eventdata, handles, varargin)
    global Nsp;
    global orgMat;
    global randOrder;
    clc;    
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    movegui(gcf,'center');
    axes(handles.axesCurBest); set(gca,'color','k','FontSize',9); set(gca, 'XTick', []); set(gca, 'yTick', []); cla(gca);
    axes(handles.axesOrgImg);  set(gca,'color','k','FontSize',9); set(gca, 'XTick', []); set(gca, 'yTick', []); cla(gca);
    axes(handles.axesWOC);     set(gca,'color','k','FontSize',9); set(gca, 'XTick', []); set(gca, 'yTick', []); cla(gca);
    axes(handles.axesFitness); set(gca,'color','w','FontSize',9); 
    
    val = get(handles.pcSlider, 'Value');
    set(handles.pcTxt, 'String', val);
    val = get(handles.pmSlider, 'Value');
    set(handles.pmTxt, 'String', val);
    set(handles.popsizeTxt, 'String', 100);
    set(handles.newRdButton, 'Value',0.0);        set(handles.savedRdButton, 'Value',1.0);
    set(findall(handles.paramsPanel, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.wocparamsPanel, '-property', 'enable'), 'enable', 'on');
    set(handles.b1Txt, 'String', num2str(3.0));   set(handles.b2Txt, 'String', num2str(3.0));
    % slider settings
    minPuzzle = 4; maxPuzzle = 11;  
    set(handles.psizeSlider, 'Min', minPuzzle);     set(handles.psizeSlider, 'Max', maxPuzzle);
    set(handles.psizeSlider, 'Value', round(maxPuzzle/2));
    set(handles.psizeSlider, 'SliderStep', [1, 1] / (maxPuzzle - minPuzzle));
    val = get(handles.psizeSlider, 'Value');
    set(handles.rowTxt, 'String', val);             set(handles.colTxt, 'String', val);
    Nsp = 5; % number of separating pixels
    fileName = feval(@(x) x{1}{x{2}},get(handles.datafileMenu,{'String','Value'}));
    if isunix  sep = '/';
    else       sep = '\'; end
    I = imread(['Images' sep fileName]);
    orgMat = tileImage(I,handles);                  % original image
    global sizeOrgImg;
    sizeOrgImg = size(I);
    [randOrder] = randImage(orgMat,size(I),handles); % initial puzzle
end
    
% --- Outputs from this function are returned to the command line.
function varargout = JigsawPuzzle_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
end

% --- Executes on button press in btn_Run.
function btn_Run_Callback(hObject, eventdata, handles)
    global orgMat;
    global sizeOrgImg;
    clearHandles(handles);
    axes(handles.axesOrgImg);
    set(gca,'color','w','FontSize',9); set(gca, 'XTick', []); set(gca, 'yTick', []);
    clc;
    fileFlag = 1;
    Nsubimages = [str2double(get(handles.rowTxt,'String')) str2double(get(handles.colTxt,'String'))];
    fileName = feval(@(x) x{1}{x{2}},get(handles.datafileMenu,{'String','Value'}));
    if get(handles.newRdButton, 'Value')==0.0    % Use pre-saved experts population
        if isunix  sep = '/';
        else       sep = '\'; end
        fileName = ['Experts' sep 'GAExpertsPop_' fileName(1:end-4) '_' num2str(Nsubimages(1)) '.mat'];
        if exist(fileName, 'file')
            expPop = load(fileName);
            expPop = expPop.expPop;
            [~,minInd] = min(expPop(:,end));
            [~] = randImage(orgMat, sizeOrgImg, handles, expPop(minInd,1:end-1), Nsubimages, 'GA');
        else % File does not exist.
          warningMessage = sprintf('Warning: file does not exist:\n%s', fileName);
          uiwait(msgbox(warningMessage));
          fileFlag = 0;
        end
    else
        % GA
        global randOrder;
        selectionType = feval(@(x) x{1}{x{2}},get(handles.selectionMenu,{'String','Value'})); %'Tournament'
        crossoverType = feval(@(x) x{1}{x{2}},get(handles.crossoverMenu,{'String','Value'})); %'one-point'
        mutationType = feval(@(x) x{1}{x{2}},get(handles.mutationMenu,{'String','Value'}));   %'swap'
        survselectionType = feval(@(x) x{1}{x{2}},get(handles.survivorselectionMenu,{'String','Value'}));  %'elitist'
        expPopSize = str2num( get(handles.popsizeTxt,'String') );
        MAX_GEN = 500;        POP_SIZE = 800; 
        Pc = str2num( get(handles.pcTxt,'String') );
        Pm = str2num( get(handles.pmTxt,'String') );
        [expPop] = GA(orgMat, randOrder, Nsubimages, selectionType, crossoverType, mutationType,...
                                survselectionType, POP_SIZE, MAX_GEN, Pc, Pm, expPopSize, handles.axesFitness, handles.axesCurBest);
        save(['GAExpertsPop_' fileName(1:end-4) '_' num2str(Nsubimages(1))],'expPop');
    end 
    if fileFlag %continue with WOC
        % Cost matrix
        b1 = str2num( get(handles.b1Txt,'String') );  b2 = str2num( get(handles.b2Txt,'String') );
        tic                          
        [cMat_Right, cMat_Down] = calcAgreementMatrix(expPop(:,1:end-1), b1, b2, Nsubimages);
        wocOrder = bestNeighborsHeuristic(cMat_Right, cMat_Down, orgMat, Nsubimages);
        wocOrder_fitness = calcFitness_LTable(wocOrder, orgMat, Nsubimages);
        [~] = randImage(orgMat, sizeOrgImg, handles, wocOrder, Nsubimages, 'WOC');
        t = toc;
        % Evaluation measure
        [crNghMeasure_GA] = neighborMeasure(expPop(minInd,1:end-1), Nsubimages);
        [crNghMeasure_WOC] = neighborMeasure(wocOrder, Nsubimages);

        set(handles.fitnessTxt, 'String', num2str(wocOrder_fitness));
        set(handles.crneighborsTxt, 'String', [num2str(crNghMeasure_WOC) ' %']);
        set(handles.maxTxt, 'String', num2str(max(expPop(:,end))));
        set(handles.minTxt, 'String', num2str(min(expPop(:,end))));
        set(handles.avgTxt, 'String', num2str(mean(expPop(:,end))));
        set(handles.gacrneighborsTxt, 'String', [num2str(crNghMeasure_GA) ' %']);
        set(handles.timeTxt, 'String', num2str(t));
    end
end

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
    file = uigetfile('*.fig');
    if ~isequal(file, 0)
        open(file);
    end
end
    
% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
    printdlg(handles.figure1)
end
    
% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
    selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                         ['Close ' get(handles.figure1,'Name') '...'],...
                         'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end
    delete(handles.figure1)
end

% --- Executes on selection change in crossoverMenu.
function crossoverMenu_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function crossoverMenu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
         set(hObject,'BackgroundColor','white');
    end
    string_list = {'1-Point','n-Point','uniform','commonLength'};
    set(hObject, 'String', string_list);
end

% --- Executes on selection change in mutationMenu.
function mutationMenu_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function mutationMenu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    string_list = {'swap','inversion','insert','scramble'};
    set(hObject, 'String', string_list);
end

% --- Executes on slider movement.
function pcSlider_Callback(hObject, eventdata, handles)
    val = num2str(get(handles.pcSlider, 'Value'));
    set(handles.pcTxt, 'String', val);
end

% --- Executes during object creation, after setting all properties.
function pcSlider_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% --- Executes on slider movement.
function pmSlider_Callback(hObject, eventdata, handles)
    val = num2str(get(handles.pmSlider, 'Value'));
    set(handles.pmTxt, 'String', val);
end
    
% --- Executes during object creation, after setting all properties.
function pmSlider_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

function pcTxt_Callback(hObject, eventdata, handles)
    textValue = str2num( get(handles.pcTxt,'String') );
    set(handles.pcSlider,'Value',textValue);
end
    
% --- Executes during object creation, after setting all properties.
function pcTxt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function pmTxt_Callback(hObject, eventdata, handles)
    textValue = str2num( get(handles.pmTxt,'String') );
    set(handles.pmSlider,'Value',textValue);
end
    
% --- Executes during object creation, after setting all properties.
function pmTxt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function popsizeTxt_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function popsizeTxt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in survivorselectionMenu.
function survivorselectionMenu_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function survivorselectionMenu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    string_list = {'elitist','uniform','generational'};
    set(hObject, 'String', string_list);
end

% --- Executes on selection change in selectionMenu.
function selectionMenu_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function selectionMenu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    string_list = {'Tournament','Random','Rank_Linear'};
    set(hObject, 'String', string_list);
end

% --- Executes on selection change in datafileMenu.
function datafileMenu_Callback(hObject, eventdata, handles) 
    global orgMat;
    global randOrder;
    global sizeOrgImg;
    if isunix  sep = '/';
    else       sep = '\'; end
    I = imread(['Images' sep feval(@(x) x{1}{x{2}},get(handles.datafileMenu,{'String','Value'}))]);
    orgMat = tileImage(I, handles);
    sizeOrgImg = size(I);
    randOrder = randImage(orgMat,size(I), handles); % initial puzzle
    clearHandles(handles);
end    
    
% --- Executes during object creation, after setting all properties.
function datafileMenu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    if isunix  sep = '/';
    else       sep = '\'; end
    list=dir(['Images' sep '*.jpg']);               %get info of files/folders in current directory
    filenames={list(~[list.isdir]).name}; %determine index of files vs folders and create cell array of file names
    set(hObject, 'String', filenames);
end

% --- Executes when selected object is changed in uipanel8.
function uipanel8_SelectionChangeFcn(hObject, eventdata, handles)
    if get(handles.newRdButton, 'Value')==0.0
        set(findall(handles.paramsPanel, '-property', 'enable'), 'enable', 'off');
        set(findall(handles.wocparamsPanel, '-property', 'enable'), 'enable', 'on');
    else
        set(findall(handles.paramsPanel, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.wocparamsPanel, '-property', 'enable'), 'enable', 'off');
    end
end

function b1Txt_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function b1Txt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function b2Txt_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function b2Txt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function rowTxt_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function rowTxt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function colTxt_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function colTxt_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on slider movement.
function psizeSlider_Callback(hObject, eventdata, handles)
    val = num2str(get(handles.psizeSlider, 'Value'));
    set(handles.rowTxt, 'String', val);
    set(handles.colTxt, 'String', val);
    global orgMat;
    global randOrder;
    global sizeOrgImg;
    if isunix  sep = '/';
    else       sep = '\'; end
    I = imread(['Images' sep feval(@(x) x{1}{x{2}},get(handles.datafileMenu,{'String','Value'}))]);
    orgMat = tileImage(I,handles);                  % original image
    sizeOrgImg = size(I);
    [randOrder] = randImage(orgMat,sizeOrgImg,handles); % initial puzzle
    axes(handles.axesWOC);     cla(gca);
    clearHandles(handles);
end

% --- Executes during object creation, after setting all properties.
function psizeSlider_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

%% Display the original puzzle
function orgMat = tileImage(I, handles)
    global Nsp;
    I = im2double(I);
    Nsubimages = [str2double(get(handles.rowTxt,'String')) str2double(get(handles.colTxt,'String'))];
    sz = size(I);
    sznew = [sz(1:2) + (Nsubimages - 1)*Nsp size(I, 3)];
    Inew = zeros(sznew);
    ind1 = [1:fix(sz(1)/Nsubimages(1)):sz(1)]; %round(linspace(1, sz(1), Nsubimages(1) + 1));
    if rem(sz(1),Nsubimages(1))==0 ind1 = [ind1 sz(1)+rem(sz(1),Nsubimages(1))]; end 
    ind2 = [1:fix(sz(2)/Nsubimages(2)):sz(2)]; %round(linspace(1, sz(2), Nsubimages(2) + 1));
    if rem(sz(2),Nsubimages(2))==0 ind2 = [ind2 sz(2)+rem(sz(2),Nsubimages(2))]; end
    index = 1;
    for i = 1:length(ind1)-1
      for j = 1:length(ind2)-1
        i1 = ind1(i):ind1(i+1)-1;
        i2 = ind2(j):ind2(j+1)-1;
        Inew(i1 + (i-1)*Nsp, i2 + (j-1)*Nsp, :) = I(i1, i2, :);
        
        subImg = I(i1, i2, :);
        if (j==length(ind2)-1 && length(i2)<tmpi2)
            diff = tmpi2-length(i2);
            i2diff = i2(end):i2(end)+diff-1;
            Inew(i1 + (i-1)*Nsp, i2diff + (j-1)*Nsp, :) = I(i1, i2(end-diff+1:end), :);
            subImg = [subImg I(i1, i2(end-diff+1:end), :)];
        else tmpi2 = length(i2);
        end
        if (i==length(ind1)-1 && length(i1)<tmpi1)
            diff = tmpi1-length(i1);
            i1diff = i1(end):i1(end)+diff-1;
            Inew(i1diff + (i-1)*Nsp, i2 + (j-1)*Nsp, :) = I(i1(end-diff+1:end), i2, :);
            if j==length(ind2)-1
                subImg = [subImg; I(i1(end-diff+1:end), i2, :)];
            else
                subImg = [subImg; I(i1(end-diff+1:end), i2, :)];
            end
        else tmpi1 = length(i1);
        end
        
        orgMat{index} = subImg;
        index = index+1;
      end
    end
    axes(handles.axesOrgImg); imshow(Inew);
end

%% Create the initial puzzle
function [randOrder] = randImage(orgMat, sz, handles, curOrder, Nsubimages, type)
    global Nsp;
    if nargin==3 
        row = str2double(get(handles.rowTxt,'String'));
        col = str2double(get(handles.colTxt,'String'));
        randOrder = randperm(row*col);
    else
        row = Nsubimages(1); col = Nsubimages(2);
        randOrder = curOrder;
    end
    initialMat = orgMat(randOrder);
    index = 1;
    sznew = [sz(1:2) + ([row col] - 1)*Nsp size(initialMat{index}, 3)];
    Inew = zeros(sznew);
    for i = 1:row
      for j = 1:col
        i1 = [(i-1)*size(initialMat{index},1)+1:i*size(initialMat{index},1)];
        i2 = [(j-1)*size(initialMat{index},2)+1:j*size(initialMat{index},2)];
        Inew(i1 + (i-1)*Nsp, i2 + (j-1)*Nsp, :) = initialMat{index};
        index = index+1;
      end
    end
    if nargin==3              axes(handles.axesCurBest); imshow(Inew);
    elseif strcmp(type,'WOC') axes(handles.axesWOC); imshow(Inew);
    elseif strcmp(type,'GA')  axes(handles.axesCurBest); imshow(Inew);
    end
end

%% Evaluation measure based on neighbor comparison
function [crNghMeasure] = neighborMeasure(bestOrder, Nsubimages)
    orgOrder = (1:Nsubimages(1)*Nsubimages(2));
    orgImg = reshape(orgOrder,Nsubimages(1),Nsubimages(2))';
    bestImg = reshape(bestOrder,Nsubimages(1),Nsubimages(2))';
    crNghMeasure = 0;
    for row=1:Nsubimages(1)
        for col = 1:Nsubimages(2)
            borders = extractBorders(row,col,Nsubimages);
            [orgRow,orgCol] = find(orgImg==bestImg(row,col));
            orgborders = extractBorders(orgRow,orgCol,Nsubimages);
            crNeighbors = 0;
            if borders(1)~=0 && orgborders(1)~=0 %right
                crNeighbors = crNeighbors+(bestImg(row,col+1)==orgImg(orgRow,orgCol+1));  end
            if borders(2)~=0 && orgborders(2)~=0 %left
                crNeighbors = crNeighbors+(bestImg(row,col-1)==orgImg(orgRow,orgCol-1));  end
            if borders(3)~=0 && orgborders(3)~=0 %top
                crNeighbors = crNeighbors+(bestImg(row-1,col)==orgImg(orgRow-1,orgCol));  end
            if borders(4)~=0 && orgborders(4)~=0 %bottom
                crNeighbors = crNeighbors+(bestImg(row+1,col)==orgImg(orgRow+1,orgCol));  end
            crNghMeasure = crNghMeasure+crNeighbors;
        end
    end
    crNghMeasure = (crNghMeasure/length(bestOrder))*(100/4);
end

function borders = extractBorders(row,col,Nsubimages)
    borders = ones(1,4);   %[right left top bottom]
    if     row==1             borders(3)=0; 
    elseif row==Nsubimages(1) borders(4)=0; end
    if     col==1             borders(2)=0; 
    elseif col==Nsubimages(2) borders(1)=0; end
end

%% Reset text boxes
function clearHandles(handles)
    set(handles.gacrneighborsTxt, 'String', '');   set(handles.fitnessTxt, 'String', '');
    set(handles.timeTxt, 'String', '');            set(handles.avgTxt, 'String', '');
    set(handles.maxTxt, 'String', '');             set(handles.minTxt, 'String', '');
    set(handles.crneighborsTxt, 'String', '');
    axes(handles.axesWOC);     cla(gca);
end

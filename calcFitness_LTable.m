%% Fitness evaluation function based on distance of the borders of subimages
function [Fitness] = calcFitness_LTable(Population, orgMat, Nsubimages, rightLTable, downLTable)
    if nargin==3 
        [rightLTable,downLTable] = calcLTables(orgMat,Nsubimages);
    end
    Fitness = zeros(size(Population,1),1);
    for i = 1:size(Population,1)
        tmpImg = reshape(Population(i,:),Nsubimages(1),Nsubimages(2))';
        mse = 0;
        for row=1:Nsubimages(1)
            borders = ones(1,4);   %[right left top bottom]
            if     row==1             borders(3)=0; 
            elseif row==Nsubimages(1) borders(4)=0; end
            for col = 1:Nsubimages(2)
                if     col==1             borders(2)=0; 
                elseif col==Nsubimages(2) borders(1)=0; 
                else   borders(1)=1;      borders(2)=1; end
                diff = 0;
                if borders(1)~=0 diff = diff+rightLTable(tmpImg(row, col),tmpImg(row, col+1)); end
                if borders(2)~=0 diff = diff+rightLTable(tmpImg(row, col-1),tmpImg(row, col)); end
                if borders(3)~=0 diff = diff+downLTable(tmpImg(row-1, col),tmpImg(row, col));  end
                if borders(4)~=0 diff = diff+downLTable(tmpImg(row, col),tmpImg(row+1, col));  end
                if diff~=0       mse = mse+(diff/(nnz(borders)*length(orgMat{1})));            end
            end
        end
        Fitness(i,1) = mse;
    end
end 

%% Compute distance lookup table for right and down directions
function [rightLTable,downLTable] = calcLTables(orgMat,Nsubimages) 
    size = Nsubimages(1)*Nsubimages(2);
    rightLTable = ones(size,size).*-1;
    downLTable = ones(size,size).*-1;
    for i = 1:size
        for j = 1:size
            if i~=j
                diff = imabsdiff(orgMat{i}(:,end,:),orgMat{j}(:,end,:));
                mse = double(sqrt(sum(sum(sum(diff.^2)))));
                rightLTable(i,j) = mse;
                diff = imabsdiff(orgMat{i}(end,:,:),orgMat{j}(1,:,:));
                mse = double(sqrt(sum(sum(sum(diff.^2)))));
                downLTable(i,j) = mse;
            end
        end
    end
end
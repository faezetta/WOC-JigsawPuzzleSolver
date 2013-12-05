%% Using a heuristic algorithm for solving Jigsaw Puzzle with the goal of cost minimization
function [wocOrder] = bestNeighborsHeuristic (cMat_Right, cMat_Down, orgMat, Nsubimages)
    puzzle={};
    cMat_Left = cMat_Right';
    cMat_Up = cMat_Down';
    [row_r,col_r]=find(cMat_Right==min(min(cMat_Right)));
    [row_d,col_d]=find(cMat_Down==min(min(cMat_Down)));
    if min(min(cMat_Right))<=min(min(cMat_Down))
        puzzle = [row_r(1) col_r(1)];
    else
        puzzle = [row_d(1);col_d(1)];
    end
    pieces = [unique(puzzle)];
    remainingPieces = setxor([1:length(cMat_Right)], pieces);
    while(~isempty(remainingPieces))
        bestNeighbors = 100*ones(numel(puzzle),3);
        for index=1:numel(puzzle)
            if puzzle(index)~=0
                [row, col] = ind2sub(size(puzzle),index);
                borders = zeros(1,4);      %[right left top bottom]
                if (row==1 && size(puzzle,1)<Nsubimages(1)) || (row>1 && puzzle(row-1,col)==0)                           borders(3)=1; end
                if (row==size(puzzle,1) && size(puzzle,1)<Nsubimages(1)) || (row<size(puzzle,1) && puzzle(row+1,col)==0) borders(4)=1; end
                if (col==1 && size(puzzle,2)<Nsubimages(2)) || (col>1 && puzzle(row,col-1)==0)                           borders(2)=1; end
                if (col==size(puzzle,2) && size(puzzle,2)<Nsubimages(2)) || (col<size(puzzle,2) && puzzle(row,col+1)==0) borders(1)=1; end
                borderVals = 100*ones(2,4);
                if borders(1)~=0 [borderVals(1,1),borderVals(2,1)]=findBestMatch(cMat_Right(puzzle(index),:),puzzle); end
                if borders(2)~=0 [borderVals(1,2),borderVals(2,2)]=findBestMatch(cMat_Left(puzzle(index),:),puzzle); end
                if borders(3)~=0 [borderVals(1,3),borderVals(2,3)]=findBestMatch(cMat_Up(puzzle(index),:),puzzle); end
                if borders(4)~=0 [borderVals(1,4),borderVals(2,4)]=findBestMatch(cMat_Down(puzzle(index),:),puzzle); end
                
                [bestNeighbors(index,1), bestNeighbors(index,2)] = min(borderVals(1,:));
                bestNeighbors(index,3) = borderVals(2,bestNeighbors(index,2));
            end
        end 
        [~,minCell] = min(bestNeighbors(:,1));
        [row, col] = ind2sub(size(puzzle),minCell);
        switch bestNeighbors(minCell,2)
            case 1  
                puzzle(row, col+1) = bestNeighbors(minCell,3);
            case 2  
                if col==1
                    puzzle = [zeros(size(puzzle,1),1) puzzle];
                    puzzle(row, 1) = bestNeighbors(minCell,3);
                else
                    puzzle(row, col-1) = bestNeighbors(minCell,3);
                end
            case 3  
                if row==1
                    puzzle = [zeros(1,size(puzzle,2));puzzle];
                    puzzle(1, col) = bestNeighbors(minCell,3);
                else
                    puzzle(row-1, col) = bestNeighbors(minCell,3);
                end
            case 4  
                puzzle(row+1, col) = bestNeighbors(minCell,3);
        end
        remainingPieces(remainingPieces==bestNeighbors(minCell,3)) = [];
    end
    wocOrder = reshape(puzzle',1,Nsubimages(1)*Nsubimages(2));
end

%% Check for duplicates
function [minVal, minInd] = findBestMatch(cMat, puzzle)
    [cMat_Sorted, ind_Sorted] = sort(cMat);
    minInd = 1;
    minVal=cMat_Sorted(minInd);
    while (sum(any(puzzle==ind_Sorted(minInd)))>0)
        minInd = minInd+1;
        minVal=cMat_Sorted(minInd);
    end
    minInd = ind_Sorted(minInd);
end

%% Collecting all individuals’ solutions into a n × n agreement matrix, 
% where n is the number of pieces of the puzzle. 
% Each cell aij in the matrix records the proportion of individuals that set cities i and j as neighbors.
function [cMat_Right,cMat_Down] = calcAgreementMatrix(expPop, b1, b2, Nsubimages)
    [popSize puzzleNum] = size(expPop);
    aMat_Right = zeros(puzzleNum);
    aMat_Down = zeros(puzzleNum);
    for i = 1:popSize
        for j = 1:puzzleNum-1
            if mod(j,Nsubimages(2))~=0
                aMat_Right(expPop(i,j),expPop(i,j+1)) = aMat_Right(expPop(i,j),expPop(i,j+1))+1;
            end
            if j<=puzzleNum-Nsubimages(2)
                aMat_Down(expPop(i,j),expPop(i,j+Nsubimages(2))) = aMat_Down(expPop(i,j),expPop(i,j+Nsubimages(2)))+1;
            end
        end
    end
    aMat_Right = aMat_Right/popSize;
    aMat_Down = aMat_Down/popSize;
    % Transforming agreement into costs
    cMat_Right = arrayfun(@(x) 1-betaincinv(x,b1,b2), aMat_Right);
    cMat_Down = arrayfun(@(x) 1-betaincinv(x,b1,b2), aMat_Down);
end

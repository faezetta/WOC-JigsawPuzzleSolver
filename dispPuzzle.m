% Display current version of Puzzle
function dispPuzzle(orgMat, bestOrder, Nsubimages, axesCurBest)
    global Nsp;
    curMat = orgMat(bestOrder);
    index = 1;
    sz = [size(curMat{1},1)*Nsubimages(1) size(curMat{1},2)*Nsubimages(2)];
    sznew = [sz(1:2) + (Nsubimages - 1)*Nsp size(curMat{index}, 3)];
    Inew = ones(sznew);
    for i = 1:Nsubimages(1)
      for j = 1:Nsubimages(2)
        i1 = [(i-1)*size(curMat{index},1)+1:i*size(curMat{index},1)];
        i2 = [(j-1)*size(curMat{index},2)+1:j*size(curMat{index},2)];
        Inew(i1 + (i-1)*Nsp, i2 + (j-1)*Nsp, :) = curMat{index};
        index = index+1;
      end
    end
    axes(axesCurBest); imshow(Inew);
end
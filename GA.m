%% Genetic Algorithm approach to Jigsaw Puzzles
function [Best_chrom_run] = GA(orgMat, randOrder, Nsubimages, selectionType, crossoverType, mutationType, survselectionType, POP_SIZE, MAX_GEN, Pc, Pm, run, axesFitness, axesCurBest, cMat)

    iterCrit = 30;
    [rightLTable,downLTable] = calcLTables(orgMat,Nsubimages);
    % Variabes Initialization---------------------------------------------- 
    BestFit = zeros(1,MAX_GEN);
    chromlength = length(randOrder);      % length of each gene inside population

    BestFit_runs = zeros(1,MAX_GEN);
    WorstFit_runs = zeros(1,MAX_GEN);
    AvgFit_runs = zeros(1,MAX_GEN);
    Best_chrom_run = zeros(run,chromlength+1);
    Best_chrom_gen = zeros(MAX_GEN,chromlength+1);
    % Main loop of genetic algorithm---------------------------------------
    for run_no = 1:run
        %First population initialization
        Population = zeros(POP_SIZE,chromlength);
        Population(1,:) = randOrder;
        for i=2:POP_SIZE
            Population(i,:) = randperm(chromlength);
        end
        %Main loop of each generation
        SurvEval = calcFitness_LTable(Population, orgMat, Nsubimages, rightLTable, downLTable);
        Survivors = Population;
        for GenCounter = 1:MAX_GEN
            %Parent seletion    
            [Parents,ParsEval] =Selection(Survivors,SurvEval,selectionType);
            %Recombiation
            Offsprings_XO = Recombination(Parents,Pc,crossoverType);
            %Mutation
            Offsprings = Mutation(Offsprings_XO,mutationType,Pm);
            %Children evaluation
            OffsEval = calcFitness_LTable(Offsprings, orgMat, Nsubimages, rightLTable, downLTable);
            %Choosing survivals
            [Survivors,SurvEval] = SurvivorSelection(Parents,ParsEval,Offsprings,OffsEval,survselectionType,POP_SIZE);
            %Checking results
            [BestFit(run_no,GenCounter),idx] = min(SurvEval); 
            WorstFit(run_no,GenCounter) = max(SurvEval);
            AvgFit(run_no,GenCounter) = mean(SurvEval);
            Best_chrom_gen(GenCounter,1:chromlength) = Survivors(idx,:);
            Best_chrom_gen(GenCounter,chromlength+1) = BestFit(run_no,GenCounter);
            
            updateDispFitness(Best_chrom_gen(1:GenCounter,end), WorstFit(run_no,1:GenCounter), AvgFit(run_no,1:GenCounter),...
                               GenCounter, MAX_GEN, axesFitness); %pause(0.2);
            dispPuzzle(orgMat, Best_chrom_gen(GenCounter,1:end-1), Nsubimages, axesCurBest);
            % stop GA if last iterCrit iterations have been the same
            % sum(abs(diff(a))) == 0
            if GenCounter>iterCrit && numel(unique(Best_chrom_gen(GenCounter-iterCrit:GenCounter,end)))==1  
                Best_chrom_gen(GenCounter+1:end,end) = Best_chrom_gen(GenCounter,end);
                break;
            end
        end
        [~,idxgen] = min(Best_chrom_gen(:,chromlength+1));
        Best_chrom_run(run_no,:) = Best_chrom_gen(idxgen,:);
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

%% Display fitness variation
function updateDispFitness  (minFit, maxFit, avgFit, curGen,MAX_GEN, axesFitness)
    axes(axesFitness); cla;
    hold on
    plot([1:curGen],minFit,'-r','LineWidth',1);
    plot([1:curGen],maxFit,'-b','LineWidth',1);
    plot([1:curGen],avgFit,'-k','LineWidth',1);
    xlim([1 MAX_GEN]); set(gca, 'XColor', [1 1 1],'YColor', [1 1 1]);
    legend('Best Fitness','Worst Fitness','Mean Fitness');
    hold off
end
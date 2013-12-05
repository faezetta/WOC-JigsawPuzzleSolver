%% The offspring are inserted into the population replacing the parents, producing a new generation
function [Survivors,SurvEval] = SurvivorSelection(oldpop,oldeval,newpop,neweval,type,POP_SIZE)
    EliteCount  =   10/100;
    [POP,CHROM] = size(newpop);
    POPSurv = POP_SIZE;

    switch type
        case 'generational'
            [pop,popeval] = reinisertion_generational(oldpop,oldeval,newpop,neweval);
        case 'uniform'
            [pop,popeval] = reinsertion_uniform(oldpop,oldeval,newpop,neweval);
        case 'elitist'
            [pop,popeval] = reinsertion_elitism(oldpop,oldeval,newpop,neweval);
        case 'mu_plus_landa'
            [pop,popeval] = reinsertion_mu_plus_landa(oldpop,oldeval,newpop,neweval);  
        case 'mu_and_landa'
            [pop,popeval] = reinsertion_mu_and_landa(newpop,neweval);
       case 'Rank_Linear'
            [pop,popeval] = Selection_Rank_Linear(oldpop,oldeval,newpop,neweval); 
        case 'Rank_Exponential'
            [pop,popeval] = Selection_Rank_Exponential(oldpop,oldeval,newpop,neweval);   
    end
    Survivors(1:POP,:) = pop;
    SurvEval(1:POP,1)  = popeval;
    [~,idx] = sort(oldeval,'ascend');
    for i = 1:POPSurv-POP
        Survivors(POP+i,:) = oldpop(idx(i),:);
        SurvEval(POP+i,1) = oldeval(idx(i),1);
    end
end

%% 1-Global reinsertion 
%1-1 generational
%produce as many offspring as parents and replace all parents by the
%offspring (pure reinsertion). 
function  [pop,popeval] = reinisertion_generational(oldpop,oldeval,newpop,neweval)
    [sizee,temp]    =   size(oldpop);
    for i=1:sizee
        pop(i,:)      =   newpop(i,:);
        popeval(i)  =   neweval(i);
    end
end

%% 1-2 uniform
%produce less offspring than parents and replace parents uniformly at
%random (uniform reinsertion). 
function [pop,popeval] = reinsertion_uniform(oldpop,oldeval,newpop,neweval)
    [sizeoff,temp]=size(newpop);
    [sizepar,temp]=size(oldpop);
    if sizeoff>sizepar sizeoff=rand(1,sizepar-2);
    end
    flag=zeros(sizepar,1);
    i=1;
    while i<=sizeoff
        t = round(1 + (sizepar-1).*rand(1,1));
%         t=rand(1,sizepar);
        if ~flag(t,1)
            flag(t,1)           = 1;
            pop(t,:)            = newpop(i,:);
            popeval(t)          = neweval(i);
            i                   = i+1;
        end
    end
end

%% 1- 3 elitist
% The elitist is the recommended method. 
% At each generation, a given number of the 'least' fit parents is replaced
% by the same number of the 'most' fit offspring
function [Survivors,SurvEval] = reinsertion_elitism(Parents,ParsEval,Offsprings,OffsEval)
    [POP,CHROM] = size(Offsprings);
    %POPSurv = POP+0.25*POP;
    POPSurv = POP;
    Survivors = zeros(POPSurv,CHROM);
    SurvEval = zeros(POPSurv,1);
    Pool = [Parents;Offsprings];
    PoolEval = [ParsEval;OffsEval];
    [~,idx] = sort(PoolEval,'ascend');
    for i = 1:POPSurv
        Survivors(i,:) = Pool(idx(i),:);
        SurvEval(i,1) = PoolEval(idx(i),1);
    end
end

%% 1- 3 mu_plus_landa
function [pop,popeval] = reinsertion_mu_plus_landa(oldpop,oldeval,newpop,neweval)
    % maximization problem
    [POP,CHROM] = size(newpop);
    [sizeoff,temp] = size(newpop);
    [sizepar,temp] = size(oldpop);
    [sort_parent,ind_parent]           = sort(oldeval);
    [sort_offspring,ind_offspring]     = sort(neweval);
    j = sizepar;
    k = sizeoff;
    i=1;
    while i<=POP && j>0 && k>0
        if sort_parent(j)>=sort_offspring(k)
            temppop(i,:)          =   oldpop(ind_parent(j),:);
            tempeval(i)           =   oldpeval(ind_parent(j));
            j=j-1;
         else
            if sort_parent(j)<sort_offspring(k)
                temppop(i,:)      =   newpop(ind_offspring(k),:);
                tempeval(i)        =   neweval(ind_offspring(k));
                k=k-1;
            end
        end
        i=i+1;
    end
    pop = temppop;
    popeval = tempeval;
end

%% 1- 3 mu_and_landa
function [pop,popeval] = reinsertion_mu_and_landa(newpop,neweval)
    % maximization problem
    [~,ind_offspring]     = sort(neweval);
    [sizeoff,temp] = size(newpop);
    j = sizeoff;
    for i=1:POP
        temppop(i,:)      =   newpop(ind_offspring(j),:);
        tempeval(i)       =   neweval(ind_offspring(j));
        j=j-1;
    end
    pop=temppop;
    popeval = tempeval;
end

%%ranking selection - linear
function [Survivors,SurvEval] = Selection_Rank_Linear(oldpop,oldeval,newpop,neweval)
    [POP,CHROM] = size(oldpop);
    POPSurv = POP;
    PopEval = [oldeval;neweval];
    Population = [oldpop;newpop];
    Survivors = zeros(POPSurv,CHROM);
    SurvEval = zeros(POPSurv,1);
    Probability = zeros(POP,1);
    S = 2;
    [~,idx] = sort(PopEval,'ascend');
    Prob = (2-S)/POP + (2*(idx-1)*(S-1))/(POP*(POP-1));
    Probability(1) = Prob(1);
    for i = 2:POP
        Probability(i) = Probability(i-1) + Prob(i);
    end
    for i = 1:POPSurv
        tmpval = rand;
        for j = 1:max(size(Prob))
            if(tmpval < Probability(j))
                Survivors(i,:) = Population(j,:);
                SurvEval(i,1) = PopEval(j,1);
                break;
            end
        end
    end
    [~,idx] = max(PopEval);
    Survivors(end,:) = Population(idx,:);
    SurvEval(end,1) = PopEval(idx,1);
end

%% ranking selection - exponential 
function [Survivors,SurvEval] = Selection_Rank_Exponential(oldpop,oldeval,newpop,neweval)
    [POP,CHROM] = size(Population);
    POPSurv = 0.8*POP;
    Survivors = zeros(POPSurv,CHROM);
    SurvEval = zeros(POPSurv,1);
    Prob = zeros(1,POP);
    Probability = zeros(1,POP);
    sigsum = 0;
    for(i = 1:POP)
        sigsum = sigsum + exp(-i);
    end
    C = POP - sigsum;
    [~,idx] = sort(PopEval,'ascend');
    Prob = (1-exp(-idx)) / C;
    Probability(1) = Prob(1);
    for(i = 2:max(size(Prob)))
        Probability(i) = Probability(i-1) + Prob(i);
    end
    for(i = 1:POPSurv)
        tmpval = rand;
        for(j = 1:max(size(Prob)))
            if(tmpval < Probability(j))
                Survivors(i,:) = Population(j,:);
                SurvEval(i,1) = PopEval(j,1);
                break;
            end
        end
    end
    [~,idx] = max(PopEval);
    Survivors(end,:) = Population(idx,:);
    SurvEval(end,1) = PopEval(idx,1);
end


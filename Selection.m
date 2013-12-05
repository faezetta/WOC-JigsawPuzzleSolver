%% Selection operation in genetic algorithm  
function [Survivors,SurvEval]=Selection(Population,fitness,type)
    n         = 0.6*size(Population,1); %number of selection
    ture_size = 2;                      %size of tournment
    T         = 20;                     %temperature of boltzman
    check     = 0;

    switch type
        case 'Random'
            y   =   selection_random(n); 
            check = 1;
        case 'roulette_wheel'
            y   =   selection_roulette_wheel(fitness,n);                
            check = 1;
        case 'SUS'
            y   =   selection_SUS(fitness,n);        
            check = 1;
        case 'boltzman'
            y   =   selection_Boltzman(fitness,T,n);
            check = 1;
    end
    switch type
        case 'Tournament'
            [Survivors,SurvEval] = Selection_Tournament(Population,fitness);
        case 'Rank_Linear'
            [Survivors,SurvEval] = Selection_Rank_Linear(Population,fitness); 
        case 'Rank_Exponential'
            [Survivors,SurvEval] = Selection_Rank_Exponential(Population,fitness);                
    end
    if check == 1
        Survivors        = Population(1:n,:);
        SurvEval         = fitness(1:n);
        for i=1:n
            Survivors(i) = Population(y(i));
            SurvEval(i)  = fitness(y(i));
        end
    end
end
      
%% random selection withought replacement
function y=selection_random(n)
    y=randperm(n);
end

%% roulette-wheel selection
%roulette is the traditional selection function with the probability of
%surviving equal to the fittness of i / sum of the fittness of all individuals 
function ind=selection_roulette_wheel(fitness,n)
%     totalFit = sum(fitness);
%     prob = fitness/totalFit;     %Pi=fi/(f1+f2+...+fN).
%     sumff = cumsum(prob);
    temp = max(fitness)-fitness;
    sumff = temp/sum(temp);
    % Select individuals from the oldPop to the new
    rNums = sort(rand(n,1)); 		%Generate random numbers
    i=1;    current=1;
    while current<= n
        if rNums(current)<sumff(i)
             ind(current)=i;
             current=current+1;
        else i=i+1;
        end
    end
end

%% Stochastic universal sampling    
function ind=selection_SUS(fitness,n)
    totalFit=sum(fitness);
    prob=fitness/totalFit;     %Pi=fi/(f1+f2+...+fN).
    sumff=cumsum(prob);
    current=1;
    i=1;
    r=Random(0,1/n);
    while current<= n
        while(r<=sumff(i))
            ind(current)=i;
            r=r+1/n;
            current=current+1;
        end
        i=i+1;
    end
end

%% Boltzman selection
function winner = selection_Boltzman(fitness,T,n)   
    pick=1;
    k=2;
    sizee=size(fitness,1);
    y=randperm(sizee);
    for j=1:n
        if pick+k>sizee, 
            pick=1;
            y=randperm(sizee);
        end
        if (1/(1+exp(fitness(y(pick))-fitness(y(pick+1))/T)))<=(1/(1+exp(fitness(y(pick+1))-fitness(y(pick))/T)))
            winner(j)=y(pick);
        else
            winner(j)=y(pick+1);
        end
        pick=pick+2;
    end
end

%% ranking selection - linear
function [Survivors,SurvEval] = Selection_Rank_Linear(Population,PopEval)
    [POP,CHROM] = size(Population);
    POPSurv = 0.8*POP;
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
function [Survivors,SurvEval] = Selection_Rank_Exponential(Population,PopEval)
    [POP,CHROM] = size(Population);
    POPSurv = 0.8*POP;
    Survivors = zeros(POPSurv,CHROM);
    SurvEval = zeros(POPSurv,1);
    Prob = zeros(1,POP);
    Probability = zeros(1,POP);
    sigsum = 0;
    for i = 1:POP
        sigsum = sigsum + exp(-i);
    end
    C = POP - sigsum;
    [~,idx] = sort(PopEval,'ascend');
    Prob = (1-exp(-idx)) / C;
    Probability(1) = Prob(1);
    for(i = 2:max(size(Prob)))
        Probability(i) = Probability(i-1) + Prob(i);
    end
    for i = 1:POPSurv
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

%% tournament selection without replacement
function [Survivors,SurvEval] = Selection_Tournament(Population,PopEval)
    [POP,CHROM] = size(Population);
    POP = 0.8*POP;
    Survivors = zeros(POP,CHROM);
    percentage = 1; 
    for i = 1:POP
        K = 2;
        Temp = zeros(K,CHROM);
        TempEval = zeros(K,1);
        for j = 1:K
            rndnum = floor(rand*POP+1);
            Temp(j,:) = Population(rndnum,:);
            TempEval(j,1) = PopEval(rndnum,1);
        end
        [~,idx] = min(TempEval);
        Survivors(i,:) = Temp(idx,:);
        SurvEval(i,1) = TempEval(idx,1);
        clear Temp;
        clear TempEval;
    end
end

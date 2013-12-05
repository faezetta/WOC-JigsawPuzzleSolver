%% Crossover operation in genetic algorithm
function [Offsprings]=Recombination(Parents,Pc,type)
n = 3; % number of cross over points
[POP,CHROM] = size(Parents);
Offsprings = zeros(POP,CHROM);
for i = 1:2:POP
    Parent1 = Parents(i,:);
    Parent2 = Parents(i+1,:);
    if(rand < Pc)
        switch type
            case '1-point'
                [Offspring1,Offspring2] = cross_one_point(Parent1,Parent2);
            case 'n-point'
                [Offspring1,Offspring2] = cross_n_point(Parent1,Parent2,n);
            case 'uniform'
                [Offspring1,Offspring2] = cross_uniform(Parent1,Parent2);
            case 'commonLength'
                [Offspring1,Offspring2] = cross_common(Parent1,Parent2);
            otherwise
                Offspring1 = Parent1;
                Offspring2 = Parent2;
        end
        Offsprings(i,:) = Offspring1;
        Offsprings(i+1,:) = Offspring2;
    else
        Offsprings(i,:) = Parent1;
        Offsprings(i+1,:) = Parent2;
    end
end
end

%% Float and Binary Representation | one point crossover
function [Offspring1,Offspring2] = cross_one_point(Parent1,Parent2)
    [~,lchrom]=size(Parent1);
    pos=int8(rand()*lchrom);
    Offspring1=[Parent1(1:double(pos)) Parent2(double(pos)+1:lchrom)];
    Offspring2=[Parent2(1:double(pos)) Parent1(double(pos)+1:lchrom)];
    Offspring1 = fixChroms(Offspring1, Parent2, lchrom, pos);
    Offspring2 = fixChroms(Offspring2, Parent1, lchrom, pos);
end

%% Float and Binary Representation | n point crossover
function [Offspring1,Offspring2] = cross_n_point(Parent1,Parent2,n)
    Offspring1=Parent1;
    Offspring2=Parent2;
    [temp,SizeChrom]=size(Parent1);
    for i=1:n
        pos(i)=floor(temp+rand()*(SizeChrom-temp+1));
    end
    pos(n+1)=SizeChrom;
    pos=sort(pos);
    count=1;
    while(count<=n)
        for i=pos(count):pos(count+1)
            Offspring1(i)=Parent2(i);
            Offspring2(i)=Parent1(i);
        end
        count=count+2;
    end
    Offspring1 = fixChroms(Offspring1, Parent2, lchrom);
    Offspring2 = fixChroms(Offspring2, Parent1, lchrom);
end

%% Float and Binary Representation | uniform crossover | discrete crossover
function [Offspring1,Offspring2] = cross_uniform(Parent1,Parent2)
    Offspring1=Parent1;
    Offspring2=Parent2;
    [~,SizeChrom]=size(Parent1);
    for i=1:SizeChrom
        if flip(0.5)
            Offspring1(i)=Parent2(i);
            Offspring2(i)=Parent1(i);
        else
            Offspring1(i)=Parent1(i);
            Offspring2(i)=Parent2(i);
        end
    end
    Offspring1 = fixChroms(Offspring1, Parent2, SizeChrom);
    Offspring2 = fixChroms(Offspring2, Parent1, SizeChrom);
end

%% Fix Crossover outputs considering the TSP Application
function [Offspring1] = fixChroms(Offspring1, Parent2, lchrom, pos)
    if nargin==3  start = 1;
    else          start = double(pos)+1;
    end
    for i=start:lchrom
        if nnz(Offspring1(1:i)==Offspring1(i))>0
            for j = 1:lchrom
                if nnz(ismember(Offspring1,Parent2(j)))==0
                    Offspring1(i) = Parent2(j);
                end
            end
        end
    end
end
%% Common Length
function [Offspring1, Offspring2] = cross_common(Parent1, Parent2)
    Offspring1=Parent1;
    Offspring2=Parent2;
    [temp,SizeChrom]=size(Parent1);
    pos=find(Parent1==Parent2);
    n=length(pos);
    if isempty(pos)
        [Offspring1,Offspring2] = cross_uniform(Parent1,Parent2);    
    else
        pos(n+1)=SizeChrom;
        pos=sort(pos);
        count=1;
        while(count<=n)
            for i=pos(count):pos(count+1)
                Offspring1(i)=Parent2(i);
                Offspring2(i)=Parent1(i);
            end
            count=count+2;
        end
    end
    Offspring1 = fixChroms(Offspring1, Parent2, SizeChrom);
    Offspring2 = fixChroms(Offspring2, Parent1, SizeChrom);
end

%% Flip a biased coin and returns 0 or 1 
function y=flip(probability)
    if probability == 1.0      y=1;
    else
        if rand()<=probability y= 1;
        else                   y=0;
        end
    end
end
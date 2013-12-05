%% Mutation operation on one chromozme
function [Offsprings]=Mutation(Offsprings_XO,type,Pm)
    Pmut    = Pm;
    [POP,~] = size(Offsprings_XO);
    Offsprings = Offsprings_XO;
    for i = 1:POP
        chrom=Offsprings_XO(i,:);  
        switch type
            case 'swap'
                 [newchrom] = mutation_swap(chrom,Pmut);
            case 'insert'
                 [newchrom] = mutation_inserts(chrom,Pmut);
            case 'scramble'
                 [newchrom] = mutation_scramble(chrom,Pmut);
            case 'inversion'
                 [newchrom] = mutation_inversion(chrom,Pmut);
            otherwise
                 newchrom   = chrom;    
        end
        Offsprings(i,:)=newchrom;
    end
end

%% permutation representation
function [newchrom] = mutation_swap(chrom,Pmut) 
    lchrom  =   length(chrom);
    pos1    =   round(rand*lchrom + 0.5);
    pos2    =   round(rand*lchrom + 0.5);
    
    if pos1 > pos2   t = pos1; pos1 = pos2; pos2 = t;
    end
    if pos1 == pos2  pos1 = max(1,pos1-1);
    end
    if flip(Pmut) && (pos1~=1 && pos2~=1) 
        newchrom = [chrom(1:pos1-1) chrom(pos2) chrom(pos1+1:pos2-1) chrom(pos1) chrom(pos2+1:(lchrom))];
    else
        newchrom = chrom;
    end
end

%% permutation representation
function [newchrom] = mutation_inserts(chrom,Pmut)
    lchrom  =   length(chrom);
    pos1    =   round(rand*lchrom + 0.5);
    pos2    =   round(rand*lchrom + 0.5);

    if pos1 > pos2   t = pos1; pos1 = pos2; pos2 = t;
    end
    if pos1 == pos2 || abs(pos1-pos2)==1
        pos1=max(1,pos1-2);
    end
    if flip(Pmut) && (pos1~=1 && pos2~=1)
       newchrom = [chrom(1:pos1) chrom(pos2) chrom(pos1+1:pos2-1) chrom(pos2+1:lchrom)];
    else
       newchrom = chrom;
    end
end

%% permutation representation
function [newchrom] = mutation_scramble(chrom,Pmut)
    lchrom  =   length(chrom);
    pos1    =   round(rand*lchrom + 0.5);
    pos2    =   round(rand*lchrom + 0.5);
    if pos1 > pos2   t = pos1; pos1 = pos2; pos2 = t;
    end
    if pos1 == pos2  pos1=max(1,pos1-1);
    end
    y=randperm(pos2-pos1+1);
    for i=1:length(y)
        sc(i)=chrom(pos1+y(i)-1);
    end
    if flip(Pmut) && (pos1~=1 && pos2~=1)
        newchrom = [chrom(1:pos1-1) sc chrom(pos2+1:lchrom)];
    else
        newchrom = chrom;
    end
end

%% permutation representation
function [newchrom] = mutation_inversion(chrom,Pmut)
    lchrom  =   length(chrom);
    pos1    =   round(rand*lchrom + 0.5);
    pos2    =   round(rand*lchrom + 0.5);

    if pos1 > pos2    t = pos1; pos1 = pos2; pos2 = t;
    end
    if pos1 == pos2   pos1=max(1,pos1-1);
    end
    if flip(Pmut)
        newchrom = [chrom(1:pos1-1) fliplr(chrom(pos1:pos2)) chrom(pos2+1:lchrom)];
    else
        newchrom = chrom;
    end
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

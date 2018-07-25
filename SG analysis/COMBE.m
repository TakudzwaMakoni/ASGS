M = 879:150:1759;
N=6:-2:0;
MAT1 = zeros(length(N),length(M)); % matrix containg poly-order x framelength coefficient 1 values
MAT2 = zeros(length(N),length(M)); % matrix containg poly-order x framelength coefficient 1 bounds
MAT3 = zeros(length(N),length(M));
MAT4 = zeros(length(N),length(M));
for j = 1:length(M) 
    for i = 1:length(N)
        CE1MAT=[];
        C1MAT = [];
        C2MAT=[];
        CE2MAT=[];
        [~,~,C1,CE1,C2,CE2] = COFORD(N(i),M(j),'n');
        C1MAT = [C1MAT,C1];
        CE1MAT=[CE1MAT,abs(CE1(1,:)-CE1(2,:))];
        C2MAT=[C2MAT,C2];
        CE2MAT=[CE2MAT,abs(CE2(1,:)-CE2(2,:))];
    end
    MAT1(:,j) = C1MAT;
    MAT2(:,j) = CE1MAT;
    MAT3(:,j) = C2MAT;
    MAT4(:,j) = CE2MAT;
end


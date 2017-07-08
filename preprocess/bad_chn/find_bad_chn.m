function [bads] = find_bad_chn(data,len_beats)
%Valitsee huonot kanavat triggausten perusteella ja sen, kuinka paljon
%qrs triggausten määrä on vaihdellut, sekä magnetometreissä tarkistaa, että
%korrelaatio on tarpeeksi suurta
    most_common=mode(len_beats);
    mags=1:3:99;
    grads=setdiff(1:99,mags);
    
    bads=abs(len_beats-most_common)>5;
    bads(grads)=abs(len_beats(grads)-most_common)>5;
    bads(mags)=abs(len_beats(mags)-most_common)>5;
    mags=data(1:3:99,:);
    r=corrcoef(mags.');
    bads(1:3:99,:)=bads(1:3:99,:)&(mean(r)<0.95).';
end


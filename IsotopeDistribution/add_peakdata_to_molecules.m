function molecules = add_peakdata_to_molecules(molecules,charge_list,minmassdistance,th)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


cid_list=zeros(length(molecules),118);
for i=1:length(molecules);
    molecules(i).peakdata=[0 1];
    cid_list(i,:)=molecules(i).cid;
end

atomic_numbers=find(any(cid_list)>0);
sub_cid_list=cid_list(:,atomic_numbers);


for an=1:length(atomic_numbers)
    fprintf('Current atom: %s\n',atomic_number2element_name(atomic_numbers(an)));
    
    %the monoatomic distribution for the first element in the cid list:
    d=atomic_distribution(atomic_number2element(atomic_numbers(an)),1,minmassdistance,th);
    ad=d;
    
    for i=1:max(sub_cid_list(:,an))
        ind=find(sub_cid_list(:,an)==i);
        if ~isempty(ind)
            for j=1:length(ind)
                molecules(ind(j)).peakdata=convolute(molecules(ind(j)).peakdata,d);
                molecules(ind(j)).peakdata=approx_masses(molecules(ind(j)).peakdata,minmassdistance);
                molecules(ind(j)).peakdata=approx_p(molecules(ind(j)).peakdata,th);
            end
        end
        d=convolute(d,ad); %next cluster of current atom
        d=approx_masses(d,minmassdistance);
        d=approx_p(d,th);
    end
end

%multiple charged species:
fprintf('\nMultiple charged species...')
for i=find(charge_list>1)
    molecules(i).peakdata(:,1)=molecules(i).peakdata(:,1)/charge_list(i);
end
fprintf('done.\n')

end


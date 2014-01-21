function molecules2listbox(ListBox,molecules)

temp='';
for i=1:length(molecules)
    temp{i}=molecules{i}.name;
end

%if length(temp)==0
    set(ListBox,'Value',1);
%end

set(ListBox,'String',temp);


end

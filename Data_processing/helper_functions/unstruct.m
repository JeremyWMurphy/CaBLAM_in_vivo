function[] = unstruct(S)

% recursively unpack all fields in a structure/sub-structure

fn = fieldnames(S);

for i = 1:numel(fn)
    fni = string(fn(i));
    field = S.(fni);
    if (isstruct(field))
        unstruct(field);
        continue;
    end
    assignin('caller', fni, field);
end

end
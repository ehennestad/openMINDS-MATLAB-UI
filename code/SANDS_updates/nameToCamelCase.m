function nameCamelCase = nameToCamelCase(name)
    
    name = char(name);
    name = strrep(name, ',', '');

    [strInd] = regexp(name, ' ');
    strInd = strInd + 1;
    
    for i = strInd
        name(i) = upper(name(i));
    end
    
    nameCamelCase = strrep(name, ' ', '');
    nameCamelCase = string(nameCamelCase);
end
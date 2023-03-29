function metaTable = objectArrayToMetaTable(objectArray)
    
% %     propertyNames = properties(objectArray);
% %     propertyNames = setdiff(propertyNames, {'DEFAULT_VALUE', 'IS_EDITABLE', 'TableColumnFormatter', 'id'});
% %     % Skip constant/hidden properties
% % 
% %     numVariables = numel(propertyNames);
% %     numObjects = numel(objectArray);
% % 
% %     cellData = cell(numObjects, numVariables);
% % 
% %     for i = 1:numVariables
% %         for j = 1:numObjects
% %             iValue = objectArray(j).(propertyNames{i});
% %                 
% %             cellData{j,i} = iValue;
% %         end
% %     end
% %     
% %     objectTable = cell2table(cellData, 'VariableNames', propertyNames');
    
    metaTable = nansen.metadata.MetaTable(objectArray.toTable(), 'MetaTableClass', class(objectArray));
end
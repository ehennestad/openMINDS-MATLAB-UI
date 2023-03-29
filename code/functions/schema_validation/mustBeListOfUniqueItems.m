function mustBeListOfUniqueItems(value)
    assert( isequal( sort(value), unique(value)), 'Value must contain unique items' );
end

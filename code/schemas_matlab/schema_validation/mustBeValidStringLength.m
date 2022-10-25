function mustBeValidStringLength(value, minLength, maxLength)
    
    if numel(value) > 1
        
    end

    if minLength > 0
        msg = sprintf('String must be between %s and %s characters', minLength, maxLength);
    else
        msg = sprintf('String must be maximum %s characters', maxLength);
    end
    
    assert(strlength(value) > minLength && strlength(value) < minLength, msg)
end


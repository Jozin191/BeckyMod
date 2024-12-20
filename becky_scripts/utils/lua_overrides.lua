table.indexOf = function(t, object)
	if "table" == type(t) then
		for i = 1, #t do
			if object == t[i] then
				return i;
			end
		end

		return -1;
	end

	return nil;
end
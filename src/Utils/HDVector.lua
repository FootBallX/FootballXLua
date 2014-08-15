local HDVector = {}

function HDVector.extend(obj)

	function obj:push_back(val)

		self[#self + 1] = val

	end

	function obj:erase(idx)

		if (idx >= 1 and idx <= #self) then
			for i = idx, #self - 1 do
				self[i] = self[i + 1]
			end
			self[#self] = nil
		end

	end

	function obj:clear()

		for i = 1, #self do
			self[i] = nil
		end
		
	end

	function obj:copy(table)

		self:clear()
		self:add(table)

	end

	function obj:add(table)

		local len = #self
		for i = 1, #table do
			self[len + i] = table[i]
		end

	end
    
    return obj

end

return HDVector
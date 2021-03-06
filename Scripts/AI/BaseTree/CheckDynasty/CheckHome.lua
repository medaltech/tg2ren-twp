function Weight()
	
	if ScenarioGetTimePlayed() < 1 then
		return 0
	end
	
	if GetHomeBuilding("SIM", "Home") then
		if BuildingGetType("Home")==GL_BUILDING_TYPE_RESIDENCE then
			-- I have a residence home, all great.
			return 0
		else
			-- check for existing residence in my family
			if DynastyGetRandomBuilding("SIM", nil, GL_BUILDING_TYPE_RESIDENCE, "MyResidence") then
				SetHomeBuilding("SIM", "MyResidence")
				return 0
			end
		end
	end
	
	if DynastyIsShadow("SIM") then
		if SimGetOfficeLevel("SIM") < 1 then
			if DynastyGetRandomBuilding("SIM", 2, GL_BUILDING_TYPE_MINE, "MyMine") then
				return 100
			else
				return 0
			end
		end
	end

	return 100
end

function Execute()
	
	if not GetSettlement("SIM","MyCity") then
		return
	end
	
	-- find the appropiate level for my home
	local HighSociety = GetImpactValue("SIM", "HaveImmunity")
	local MyTitle = GetNobilityTitle("SIM")
	local MinResLvL = 1
	local MaxResLvL = GetDatabaseValue("NobilityTitle", MyTitle, "maxresidencelevel")
	local CityLevel = CityGetLevel("MyCity")
	local MaxLvLForCity = CityLevel
	
	if MaxLvLForCity >5 then 
		MaxLvLForCity = 5
	end
	
	if HighSociety > 0 then
		MinResLvL = MinResLvL + 1
	end
	
	if MyTitle >= 6 then
		MinResLvL = MinResLvL + 1
	end
	
	if SimGetOfficeLevel("SIM") >= 5 then
		MinResLvL = MinResLvL + 1
	end
	
	MinResLvL = MinResLvL + Rand(2)
	
	if MinResLvL > MaxResLvL then
		MinResLvL = MaxResLvL
	end
	
	if MinResLvL > MaxLvLForCity then
		MinResLvL = MaxLvLForCity
	end
	
	-- buy a new residence if possible, empty houses first
	if not CityGetRandomBuilding("MyCity", nil, GL_BUILDING_TYPE_RESIDENCE, MinResLvL, -1, FILTER_NO_DYNASTY, "Residence") then
		CityGetRandomBuilding("MyCity", nil, GL_BUILDING_TYPE_RESIDENCE, MinResLvL, -1, FILTER_IS_BUYABLE, "Residence")
	end
	
	if AliasExists("Residence") then
		BuildingBuy("Residence", "SIM", BM_STARTUP)
		return
	end
	
	-- Still no residence? Then build a new one, but only for important people
	if HighSociety > 0 or DynastyGetRandomBuilding("SIM", 2, GL_BUILDING_TYPE_MINE, "MyMine") then
		
		local Proto = ScenarioFindBuildingProto(nil, GL_BUILDING_TYPE_RESIDENCE, MinResLvL, -1)
		if Proto ~= -1 then
			if not CityBuildNewBuilding("MyCity", Proto, "SIM", "Residence") then
				return
			end
		end
	end
end
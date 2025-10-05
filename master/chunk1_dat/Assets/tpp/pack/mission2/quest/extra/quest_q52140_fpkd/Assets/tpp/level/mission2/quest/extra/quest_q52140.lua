local this = {}
local quest_step = {}

local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId

this.QUEST_TABLE = {

	questType = TppDefine.QUEST_TYPE.ELIMINATE,

	cpList = {
		{
			cpName = "quest_cp",
			cpPosition_x = -608.622,
			cpPosition_y = 278.374,
			cpPosition_z = 1694.876,
			cpPosition_r = 30.0,
			isOuterBaseCp = true,
			gtName = "gt_quest_0000",
			gtPosition_x = -608.622,
			gtPosition_y = 278.374,
			gtPosition_z = 1694.876,
			gtPosition_r = 30.0,
		},
	},

	enemyList = {
		{
			enemyName = "sol_quest_0000",
			route_d = "rt_quest_d_0000",
			route_c = "rt_quest_d_0000",
			powerSetting = {},
			rideFromVehicleId = "vehicle_quest_0000",
		},
		{
			enemyName = "sol_quest_0001",
			route_d = "rt_quest_d_0001",
			route_c = "rt_quest_d_0001",
			powerSetting = {},
			rideFromVehicleId = "vehicle_quest_0001",
		},
		{
			enemyName = "sol_quest_0002",
			route_d = "rt_quest_d_0002",
			route_c = "rt_quest_d_0002",
			powerSetting = { "SOFT_ARMOR", "HELMET", "SNIPER" },
		},
		{
			enemyName = "sol_quest_0003",
			route_d = "rt_quest_d_0003",
			route_c = "rt_quest_d_0003",
			powerSetting = { "SOFT_ARMOR", "HELMET", "SNIPER" },
		},
		{
			enemyName = "sol_quest_0004",
			route_d = "rt_quest_d_0004",
			route_c = "rt_quest_d_0004",
			powerSetting = { "SOFT_ARMOR", "HELMET", "SNIPER" },
		},
		{
			enemyName = "sol_quest_0005",
			route_d = "rt_quest_d_0005",
			route_c = "rt_quest_d_0005",
			powerSetting = { "SOFT_ARMOR", "HELMET", "SHIELD" },
		},
		{
			enemyName = "sol_quest_0006",
			route_d = "rt_quest_d_0005",
			route_c = "rt_quest_d_0005",
			powerSetting = { "SOFT_ARMOR", "HELMET", "SHOTGUN" },
		},
		{
			enemyName = "sol_quest_0007",
			route_d = "rt_quest_d_0005",
			route_c = "rt_quest_d_0005",
			powerSetting = { "SOFT_ARMOR", "HELMET", "MISSILE" },
		},
	},

	vehicleList = {
		{
			id = "Spawn",
			locator = "vehicle_quest_0000",
			type = Vehicle.type.EASTERN_WHEELED_ARMORED_VEHICLE,
			subType = Vehicle.subType.EASTERN_WHEELED_ARMORED_VEHICLE_ROCKET_ARTILLERY,
			class = Vehicle.class.OXIDE_RED,
			priority = 1,
		},
		{
			id = "Spawn",
			locator = "vehicle_quest_0001",
			type = Vehicle.type.EASTERN_WHEELED_ARMORED_VEHICLE,
			subType = Vehicle.subType.EASTERN_WHEELED_ARMORED_VEHICLE_ROCKET_ARTILLERY,
			class = Vehicle.class.OXIDE_RED,
			priority = 1,
		},
	},

	hostageList = {
		nil,
	},

	heliList = {
		{
			routeName = "rt_heli_quest_0000",
			coloringType = TppDefine.ENEMY_HELI_COLORING_TYPE.RED,
		},
	},

	targetList = {
		"vehicle_quest_0000",
		"vehicle_quest_0001",
		"sol_quest_0002",
		"sol_quest_0003",
		"sol_quest_0004",
		"sol_quest_0005",
		"sol_quest_0006",
		"sol_quest_0007",
		TppReinforceBlock.REINFORCE_HELI_NAME,
	},
}

function this.OnAllocate()
	TppQuest.RegisterQuestStepList({
		"QStep_Start",
		"QStep_Main",
		nil,
	})

	TppEnemy.OnAllocateQuestFova(this.QUEST_TABLE)

	TppQuest.RegisterQuestStepTable(quest_step)
	TppQuest.RegisterQuestSystemCallbacks({
		OnActivate = function()
			Fox.Log("quest_recv_child OnActivate")

			TppEnemy.OnActivateQuest(this.QUEST_TABLE)
		end,
		OnDeactivate = function()
			Fox.Log("quest_recv_child OnDeactivate")

			TppEnemy.OnDeactivateQuest(this.QUEST_TABLE)
		end,
		OnOutOfAcitveArea = function() end,
		OnTerminate = function()
			TppEnemy.OnTerminateQuest(this.QUEST_TABLE)
		end,
	})

	mvars.fultonInfo = TppDefine.QUEST_CLEAR_TYPE.NONE
end

this.Messages = function()
	return StrCode32Table({
		Block = {
			{
				msg = "StageBlockCurrentSmallBlockIndexUpdated",
				func = function() end,
			},
		},
	})
end

function this.OnInitialize()
	TppQuest.QuestBlockOnInitialize(this)
end

function this.OnUpdate()
	TppQuest.QuestBlockOnUpdate(this)
end

function this.OnTerminate()
	TppQuest.QuestBlockOnTerminate(this)
end

quest_step.QStep_Start = {
	OnEnter = function()
		TppQuest.SetNextQuestStep("QStep_Main")
	end,
}

quest_step.QStep_Main = {

	Messages = function(self)
		return StrCode32Table({
			GameObject = {
				{
					msg = "Dead",
					func = function(gameObjectId)
						local isClearType =
							TppEnemy.CheckQuestAllTarget(this.QUEST_TABLE.questType, "Dead", gameObjectId)

						if
							gameObjectId ~= GetGameObjectId("sol_quest_0000")
							and gameObjectId ~= GetGameObjectId("sol_quest_0001")
						then
							TppQuest.ClearWithSave(isClearType)
						end
					end,
				},
				{
					msg = "FultonInfo",
					func = function(gameObjectId)
						if mvars.fultonInfo ~= TppDefine.QUEST_CLEAR_TYPE.NONE then
							TppQuest.ClearWithSave(mvars.fultonInfo)
						end
						mvars.fultonInfo = TppDefine.QUEST_CLEAR_TYPE.NONE
					end,
				},
				{
					msg = "Fulton",
					func = function(gameObjectId)
						local isClearType =
							TppEnemy.CheckQuestAllTarget(this.QUEST_TABLE.questType, "Fulton", gameObjectId)
						mvars.fultonInfo = isClearType
					end,
				},
				{
					msg = "FultonFailed",
					func = function(gameObjectId, locatorName, locatorNameUpper, failureType)
						if failureType == TppGameObject.FULTON_FAILED_TYPE_ON_FINISHED_RISE then
							local isClearType =
								TppEnemy.CheckQuestAllTarget(this.QUEST_TABLE.questType, "FultonFailed", gameObjectId)
							TppQuest.ClearWithSave(isClearType)
						end
					end,
				},
				{
					msg = "VehicleBroken",
					func = function(gameObjectId, state)
						if state == StrCode32("End") then
							local isClearType =
								TppEnemy.CheckQuestAllTarget(this.QUEST_TABLE.questType, "VehicleBroken", gameObjectId)
							TppQuest.ClearWithSave(isClearType)
						end
					end,
				},
				{
					msg = "LostControl",
					func = function(gameObjectId, state)
						if state == StrCode32("End") then
							local isClearType =
								TppEnemy.CheckQuestAllTarget(this.QUEST_TABLE.questType, "LostControl", gameObjectId)
							TppQuest.ClearWithSave(isClearType)
						end
					end,
				},
				{
					msg = "PlacedIntoVehicle",
					func = function(gameObjectId, vehicleGameObjectId)
						if Tpp.IsHelicopter(vehicleGameObjectId) then
							local isClearType =
								TppEnemy.CheckQuestAllTarget(this.QUEST_TABLE.questType, "InHelicopter", gameObjectId)
							TppQuest.ClearWithSave(isClearType)
						end
					end,
				},
			},
		})
	end,

	OnEnter = function()
		Fox.Log("QStep_Main OnEnter")
	end,
	OnLeave = function()
		Fox.Log("QStep_Main OnLeave")
	end,
}

return this

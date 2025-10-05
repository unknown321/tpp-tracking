local this = {}
local quest_step = {}

local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId

this.QUEST_TABLE = {

	questType = TppDefine.QUEST_TYPE.RECOVERED,

	isQuestBalaclava = true,

	cpList = {
		{
			cpName = "quest_cp",
			cpPosition_x = 1601.215,
			cpPosition_y = 116.148,
			cpPosition_z = -861.379,
			cpPosition_r = 50.0,
			isOuterBaseCp = true,
			gtName = "gt_quest_0000",
			gtPosition_x = 1601.215,
			gtPosition_y = 116.148,
			gtPosition_z = -861.379,
			gtPosition_r = 20.0,
		},
	},

	enemyList = {
		{
			enemyName = "sol_quest_0000",
			route_d = "rt_quest_d_0000",
			route_c = "rt_quest_c_0000",
			powerSetting = { "SNIPER", "HELMET", "SOFT_ARMOR" },
			soldierSubType = "PF_C",
			isBalaclava = true,
		},
		{
			enemyName = "sol_quest_0001",
			route_d = "rt_quest_d_0001",
			route_c = "rt_quest_c_0001",
			powerSetting = { "HELMET" },
			soldierSubType = "PF_C",
			isBalaclava = false,
		},
		{
			enemyName = "sol_quest_0002",
			route_d = "rt_quest_d_0002",
			route_c = "rt_quest_c_0002",
			powerSetting = { "SNIPER", "HELMET", "SOFT_ARMOR" },
			soldierSubType = "PF_C",
			isBalaclava = false,
		},
		{
			enemyName = "sol_quest_0003",
			route_d = "rt_quest_d_0003",
			route_c = "rt_quest_c_0003",
			powerSetting = { "HELMET" },
			soldierSubType = "PF_C",
			isBalaclava = false,
		},
		{
			enemyName = "sol_quest_0004",
			route_d = "rt_quest_d_0004",
			route_c = "rt_quest_c_0004",
			powerSetting = { "SOFT_ARMOR", "MG" },
			soldierSubType = "PF_C",
			isBalaclava = false,
		},
		{
			enemyName = "sol_quest_0005",
			route_d = "rt_quest_d_0004",
			route_c = "rt_quest_c_0004",
			powerSetting = { "SOFT_ARMOR", "SHOTGUN" },
			soldierSubType = "PF_C",
			isBalaclava = false,
		},
	},

	vehicleList = {
		nil,
	},

	hostageList = {
		nil,
	},

	targetList = {
		"sol_quest_0000",
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
		TppUiCommand.RegisterIconUniqueInformation({
			markerId = GameObject.GetGameObjectId("sol_quest_0000"),
			langId = "marker_ene_elite",
		})
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
						TppQuest.ClearWithSave(isClearType)
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

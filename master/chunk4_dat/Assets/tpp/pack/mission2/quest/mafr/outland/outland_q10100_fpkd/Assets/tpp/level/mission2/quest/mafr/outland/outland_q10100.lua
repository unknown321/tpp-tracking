local this = {}
local quest_step = {}

local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId

this.QUEST_TABLE = {

	questType = TppDefine.QUEST_TYPE.RECOVERED,

	isQuestBalaclava = true,

	cpList = {
		nil,
	},

	enemyList = {
		{
			enemyName = "sol_quest_0000",
			route_d = "rt_quest_d_0000",
			route_c = "rt_quest_d_0000",
			cpName = "mafr_flowStation_cp",
			isBalaclava = true,
			soldierSubType = "PF_A",
			powerSetting = { "HELMET", "SOFT_ARMOR", "MG" },
		},
		{
			enemyName = "sol_quest_0001",
			route_d = "rt_quest_d_0000",
			route_c = "rt_quest_d_0000",
			cpName = "mafr_flowStation_cp",
			isBalaclava = false,
			soldierSubType = "PF_A",
			powerSetting = { "SHIELD", "HELMET", "SMG" },
		},
		{
			enemyName = "sol_quest_0002",
			route_d = "rt_quest_d_0001",
			route_c = "rt_quest_d_0001",
			cpName = "mafr_flowStation_cp",
			isBalaclava = false,
			soldierSubType = "PF_A",
			powerSetting = { "SOFT_ARMOR", "SHOTGUN" },
		},
		{
			enemyName = "sol_quest_0003",
			route_d = "rt_quest_d_0001",
			route_c = "rt_quest_d_0001",
			cpName = "mafr_flowStation_cp",
			isBalaclava = false,
			soldierSubType = "PF_A",
			powerSetting = { "SHIELD", "HELMET", "SMG" },
		},
		{
			enemyName = "sol_quest_0004",
			route_d = "rt_quest_d_0002",
			route_c = "rt_quest_d_0002",
			cpName = "mafr_flowStation_cp",
			isBalaclava = false,
			soldierSubType = "PF_A",
			powerSetting = { "SOFT_ARMOR" },
		},
		{
			enemyName = "sol_quest_0005",
			route_d = "rt_quest_d_0002",
			route_c = "rt_quest_d_0002",
			cpName = "mafr_flowStation_cp",
			isBalaclava = false,
			soldierSubType = "PF_A",
			powerSetting = { "SHIELD", "HELMET", "SMG" },
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

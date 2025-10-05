local this = {}
local quest_step = {}

local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId

this.QUEST_TABLE = {

	questType = TppDefine.QUEST_TYPE.RECOVERED,

	cpList = {
		nil,
	},

	enemyList = {
		{
			enemyName = "sol_quest_0000",
			route_d = "rt_quest_d_0000",
			route_c = "rt_quest_c_0000",
			cpName = "mafr_outland_cp",
			powerSetting = {},
			bodyId = TppDefine.QUEST_BODY_ID_LIST.Q99071,
			faceId = TppDefine.QUEST_FACE_ID_LIST.Q99071,
			uniqueTypeId = TppDefine.UNIQUE_STAFF_TYPE_ID.S10080_GUN_SMITH,
		},
		{
			enemyName = "sol_quest_0001",
			route_d = "rt_quest_d_0000",
			route_c = "rt_quest_c_0001",
			cpName = "mafr_outland_cp",
			powerSetting = { "SOFT_ARMOR", "HELMET", "MG" },
		},
		{
			enemyName = "sol_quest_0002",
			route_d = "rt_quest_d_0000",
			route_c = "rt_quest_c_0002",
			cpName = "mafr_outland_cp",
			powerSetting = { "SOFT_ARMOR", "HELMET", "SHOTGUN" },
		},
		{
			enemyName = "sol_quest_0003",
			route_d = "rt_quest_d_0000",
			route_c = "rt_quest_c_0003",
			cpName = "mafr_outland_cp",
			powerSetting = { "SOFT_ARMOR", "HELMET", "MISSILE" },
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

	TppHostage2.SetHostageType({
		gameObjectType = "TppHostageUnique",
		hostageType = "NoStand",
	})

	TppQuest.RegisterQuestStepTable(quest_step)
	TppQuest.RegisterQuestSystemCallbacks({
		OnActivate = function()
			Fox.Log("quest_recv_child OnActivate")

			TppEnemy.OnActivateQuest(this.QUEST_TABLE)

			TppInterrogation.AddQuestTable(this.uniqueInterrogation)
		end,
		OnDeactivate = function()
			Fox.Log("quest_recv_child OnDeactivate")

			TppEnemy.OnDeactivateQuest(this.QUEST_TABLE)
		end,
		OnOutOfAcitveArea = function() end,
		OnTerminate = function()
			TppEnemy.OnTerminateQuest(this.QUEST_TABLE)

			TppInterrogation.ResetQuestTable()
		end,
	})

	mvars.interrogationCount = 0

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

this.UniqueInterStart_sol_Gunsmith = function(soldier2GameObjectId, cpID)
	if mvars.interrogationCount == 0 then
		TppInterrogation.QuestInterrogation(cpID, "enqt1000_107085")
	else
		TppInterrogation.QuestInterrogation(cpID, "enqt1000_107087")
	end

	if mvars.interrogationCount < 1 then
		mvars.interrogationCount = mvars.interrogationCount + 1
	end
	return true
end

this.UniqueInterEnd_sol_Gunsmith = function(soldier2GameObjectId, cpID) end

this.uniqueInterrogation = {

	unique = {
		{ name = "enqt1000_107085", func = this.UniqueInterEnd_sol_Gunsmith },
		{ name = "enqt1000_107087", func = this.UniqueInterEnd_sol_Gunsmith },
	},

	uniqueChara = {
		{ name = "sol_quest_0000", func = this.UniqueInterStart_sol_Gunsmith },
	},
}

return this

local this = {}
local quest_step = {}

local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local GetGameObjectId = GameObject.GetGameObjectId

local TARGET_HOSTAGE_NAME01 = "hos_quest_0000"
local TARGET_HOSTAGE_NAME02 = "hos_quest_0001"

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
			cpName = "afgh_citadel_cp",
			powerSetting = { "SHIELD", "HELMET", "SHOTGUN" },
		},
		{
			enemyName = "sol_quest_0001",
			route_d = "rt_citadel_d_0020",
			route_c = "rt_citadel_c_0023",
			cpName = "afgh_citadel_cp",
			powerSetting = { "SOFT_ARMOR", "HELMET", "MG" },
		},
		{
			enemyName = "sol_quest_0002",
			route_d = "rt_quest_d_0002",
			route_c = "rt_quest_c_0002",
			cpName = "afgh_citadel_cp",
			powerSetting = { "SNIPER" },
		},
		{
			enemyName = "sol_quest_0003",
			route_d = "rt_citadel_d_0015",
			route_c = "rt_citadel_c_0020",
			cpName = "afgh_citadel_cp",
			powerSetting = { "SOFT_ARMOR", "HELMET", "SHOTGUN" },
		},
		{
			enemyName = "sol_quest_0004",
			route_d = "rt_citadel_d_0033",
			route_c = "rt_quest_c_0000",
			cpName = "afgh_citadel_cp",
			powerSetting = { "SOFT_ARMOR", "HELMET", "MG" },
		},
		{
			enemyName = "sol_quest_0005",
			route_d = "rt_quest_d_0001",
			route_c = "rt_quest_c_0001",
			cpName = "afgh_citadel_cp",
			powerSetting = { "SHIELD", "HELMET", "MG" },
		},
		{
			enemyName = "sol_quest_0006",
			route_d = "rt_citadel_d_0030",
			route_c = "rt_citadel_c_0034",
			cpName = "afgh_citadel_cp",
			powerSetting = { "SOFT_ARMOR", "HELMET", "MG" },
		},
		{
			enemyName = "sol_quest_0007",
			route_d = "rt_citadel_d_0026",
			route_c = "rt_citadel_c_0034",
			cpName = "afgh_citadel_cp",
			powerSetting = { "SNIPER" },
		},
	},

	vehicleList = {
		nil,
	},

	hostageList = {
		{
			hostageName = TARGET_HOSTAGE_NAME01,
			isFaceRandom = true,
			voiceType = { "hostage_d" },
			langType = "english",
			uniqueTypeId = TppDefine.UNIQUE_STAFF_TYPE_ID.QUEST_HOSTAGE_SR_02,
		},
		{
			hostageName = TARGET_HOSTAGE_NAME02,
			faceId = TppDefine.QUEST_FACE_ID_LIST.TAN,
			voiceType = { "hostage_c" },
			langType = "english",
			uniqueTypeId = TppDefine.UNIQUE_STAFF_TYPE_ID.QUEST_TAN,
		},
	},

	targetList = {
		TARGET_HOSTAGE_NAME01,
		TARGET_HOSTAGE_NAME02,
	},
}

this.InterCall_hostage_pos01 = function(soldier2GameObjectId, cpID, interName)
	Fox.Log("CallBack : Quest InterCall_hostage_pos01")

	TppMarker.EnableQuestTargetMarker(TARGET_HOSTAGE_NAME02)
end

this.SetAllEnemyStaffParam = function()
	TppEnemy.AssignUniqueStaffType({

		locaterName = "hos_quest_0000",
		uniqueStaffTypeId = TppDefine.UNIQUE_STAFF_TYPE_ID.QUEST_HOSTAGE_SR_02,
		alreadyExistParam = { staffTypeId = 43, randomRangeId = 5, skill = nil },
	})
end

this.questCpInterrogation = {

	{ name = "enqt1000_101528", func = this.InterCall_hostage_pos01 },
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

			this.SetAllEnemyStaffParam()
		end,
		OnDeactivate = function()
			Fox.Log("quest_recv_child OnDeactivate")

			TppEnemy.OnDeactivateQuest(this.QUEST_TABLE)
		end,
		OnOutOfAcitveArea = function() end,
		OnTerminate = function()
			this.SwitchEnableQuestHighIntTable(false, "afgh_citadel_cp", this.questCpInterrogation)

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
		this.SwitchEnableQuestHighIntTable(true, "afgh_citadel_cp", this.questCpInterrogation)
		TppQuest.SetNextQuestStep("QStep_Main")
	end,
}

quest_step.QStep_Main = {
	Messages = function(self)
		return StrCode32Table({
			Marker = {
				{
					msg = "ChangeToEnable",
					func = function(arg0, arg1)
						Fox.Log("### Marker ChangeToEnable  ###" .. arg0)
						if arg0 == StrCode32(TARGET_HOSTAGE_NAME01) then
							TppMarker.Disable("marker_hostage0000")
						elseif arg0 == StrCode32(TARGET_HOSTAGE_NAME02) then
							this.SwitchEnableQuestHighIntTable(false, "afgh_citadel_cp", this.questCpInterrogation)
						end
					end,
				},
			},
			Radio = {
				{
					msg = "Finish",
					func = function(arg0, arg1, arg2)
						Fox.Log("### Radio Finish  ###" .. arg0)
						if arg0 == StrCode32("f1000_rtrg2030") then
							TppMarker.Enable("hos_quest_0000", 0, "defend", "map_and_world_only_icon", 0, false, true)
							TppMarker.SetQuestMarker("hos_quest_0000")
							TppUiCommand.RegisterIconUniqueInformation({
								markerId = GameObject.GetGameObjectId("hos_quest_0000"),
								langId = "marker_hostage",
							})
							TppUI.ShowAnnounceLog("updateMap", nil, nil, 1)
						end
					end,
				},
			},
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
						if gameObjectId == GameObject.GetGameObjectId("TppHostageUnique", TARGET_HOSTAGE_NAME01) then
							mvars.isHostage00Rescue = true
						end
						if gameObjectId == GameObject.GetGameObjectId("TppHostageUnique", TARGET_HOSTAGE_NAME02) then
							if mvars.isHostage00Rescue == false then
								TppRadio.Play(
									{ "f1000_rtrg2030", "f1000_rtrg1500" },
									{ isEnqueue = true, delayTime = "long" }
								)
							end
						end

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
		mvars.isHostage00Rescue = false
	end,
	OnLeave = function()
		Fox.Log("QStep_Main OnLeave")
	end,
}

this.SwitchEnableQuestHighIntTable = function(flag, commandPostName, questCpInterrogation)
	local commandPostId = GameObject.GetGameObjectId("TppCommandPost2", commandPostName)

	if flag then
		TppInterrogation.SetQuestHighIntTable(commandPostId, questCpInterrogation)
	else
		TppInterrogation.RemoveQuestHighIntTable(commandPostId, questCpInterrogation)
	end
end
return this

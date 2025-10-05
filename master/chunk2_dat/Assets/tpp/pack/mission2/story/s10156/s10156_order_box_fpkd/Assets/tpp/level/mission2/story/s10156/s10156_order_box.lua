local this = {}

this.orderBoxList = {
	"box_s10156_00",
}

this.orderBoxTrapList = Tpp.StrCode32Table({
	trap_box_s10156_00 = "box_s10156_00",
})

function this.OnAllocate()
	TppScriptBlock.InitScriptBlockState()
end

function this.OnInitialize()
	order_box_block.OnInitializeOrderBoxBlock(this, this.orderBoxTrapList)
end

function this.OnUpdate()
	order_box_block.OnUpdateOrderBoxBlock(this, this.orderBoxList)
end

function this.OnTerminate()
	order_box_block.OnTerminateOrderBoxBlock(this, this.orderBoxList)
end

return this

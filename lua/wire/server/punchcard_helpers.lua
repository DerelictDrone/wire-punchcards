
function SendPunchcard(card,ply,writable)
	local Columns = card.Columns -- aka bits
	local Rows = card.Rows
	local Data,Patches = card.Data,card.Patches
	net.Start("wire_punchcard_data")
	net.WriteEntity(card)
	net.WriteUInt(Columns,16)
	net.WriteUInt(Rows,16)
	net.WriteBool(writable and true or false) -- write allowed
	net.WriteString(card.pc_model)
	net.WriteString(card.pc_name or "")
	for _,i in ipairs(Data) do
		net.WriteUInt(i,Columns)
	end
	for _,i in ipairs(Patches) do
		net.WriteUInt(i,Columns)
	end
	net.Send(ply)
end
local plymeta = FindMetaTable("Player")

if SERVER then
	util.AddNetworkString("TTT2UpdateDisguiserTarget")
	util.AddNetworkString("TTT2ToggleDisguiserTarget")

	function plymeta:UpdateStoredDisguiserTarget(target, model, skin)
		self.storedDisguiserTarget = target
		self.disguiserStoredModel = model
		self.disguiserStoredSkin = skin

		net.Start("TTT2UpdateDisguiserTarget")
		net.WriteEntity(target)
		net.Send(self)

		if not IsValid(target) or not target:IsPlayer() then return end

		LANG.Msg(self, "identity_disguiser_new_target", {name = target:Nick()}, MSG_MSTACK_PLAIN)
	end

	function plymeta:ActivateDisguiserTarget()
		if not self:HasStoredDisguiserTarget() then return end

		self.disguiserTargetActivated = true
		self.disguiserTarget = self.storedDisguiserTarget

		net.Start("TTT2ToggleDisguiserTarget")
		net.WriteBool(true)
		net.WriteEntity(self)
		net.WriteEntity(self.storedDisguiserTarget)
		net.Broadcast()

		-- UPDATE MODEL
		self.disguiserDefaultModel = self:GetModel()
		self.disguiserDefaultSkin = self:GetSkin()

		if self.disguiserStoredModel then
			self:SetModel(self.disguiserStoredModel)
		end

		if self.disguiserStoredSkin then
			self:SetSkin(self.disguiserStoredSkin)
		end
	end

	function plymeta:DeactivateDisguiserTarget()
		self.disguiserTargetActivated = false
		self.disguiserTarget = nil

		net.Start("TTT2ToggleDisguiserTarget")
		net.WriteBool(false)
		net.WriteEntity(self)
		net.Broadcast()

		-- UPDATE MODEL
		if self.disguiserDefaultModel then
			self:SetModel(self.disguiserDefaultModel)

			self.disguiserDefaultModel = nil
		end

		if self.disguiserDefaultSkin then
			self:SetSkin(self.disguiserDefaultSkin)

			self.disguiserDefaultSkin = nil
		end
	end

	function plymeta:ToggleDisguiserTarget()
		if self.disguiserTargetActivated then
			self:DeactivateDisguiserTarget()
		else
			self:ActivateDisguiserTarget()
		end
	end
end

if CLIENT then
	net.Receive("TTT2UpdateDisguiserTarget", function()
		LocalPlayer().storedDisguiserTarget = net.ReadEntity()
	end)

	net.Receive("TTT2ToggleDisguiserTarget", function()
		local addDisguise = net.ReadBool()
		local owner = net.ReadEntity()

		if not IsValid(owner) then return end

		if addDisguise then
			owner.disguiserTarget = net.ReadEntity()
		else
			owner.disguiserTarget = nil
		end
	end)
end

function plymeta:HasDisguiserTarget()
	return IsValid(self.disguiserTarget)
end

function plymeta:HasStoredDisguiserTarget()
	return IsValid(self.storedDisguiserTarget)
end

function plymeta:GetDisguiserTarget()
	return self.disguiserTarget
end

function plymeta:GetStoredDisguiserTarget()
	return self.storedDisguiserTarget
end

init_remote_spy = loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))
print(pcall(init_remote_spy))

-- GG! Arceus X Support
game:GetService("CoreGui"):WaitForChild("SimpleSpy2"):WaitForChild("Background").Position = UDim2.new(0, 200, 0, 50)

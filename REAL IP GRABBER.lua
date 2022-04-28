--[[
    FBI WARNING!!! THIS IS A REAL IP GRABBER!!! USE ON YOUR OWN RISK!!!
]]

--[[
    FGHGK's IP Grabber
    Instantly grab IP using page html source code
    Grab someone IP and know where they live
    Discoved by FGHGK3478
    By FGHGK3478
]]


local arg = {
  -- change this to any web url that display ip address
  Url = "https://myip.com"
}

content = request(arg)

-- grab the ip address from html code

ip = content.Body:match("%d+%.%d+%.%d+%.%d+")

print("Status Code : "..tostring(content.StatusCode))
print("Your IP : "..ip)

-- to get someone ip, they have to execute the script
-- then send the ip to api or discord server to get the ip

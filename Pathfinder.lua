--/ Scripted by MinhXD#9978
--/ This pathfinder uses A Star algorithm. You can learn it from here https://youtu.be/-L-WgKMFuhE
--/ Feel free to use this but don't forgot to give credits


local Config

local pathFinder = {};
local Nodes = {};
local openNodes = {};
local closedNodes = {};
local cameFrom = {};
local gScore = {};
local hScore = {};
local fScore = {};
local newVec3 = Vector3.new;
local newVec2 = Vector2.new;
local insert = table.insert;
local floor = math.floor;

--/ Physics

function Distance(startPos, goalPos)
    return (startPos - goalPos).Magnitude;
end

--/ Node

function Nodes:New(Pos, startPos, endPos, spacing)

    Pos = newVec3(floor(Pos.X), floor(Pos.Y), floor(Pos.Z));
    
    if Nodes[Pos.X] == nil then
        Nodes[Pos.X] = {};
    end
    if Nodes[Pos.X][Pos.Y] == nil then
        Nodes[Pos.X][Pos.Y] = {};
    end

    local newNode = {};
    
    newNode.Position = Pos;
    
    gScore[newNode] = 1/0;
    fScore[newNode] = 1/0;
    
    if Config["showNodes"] then
        newNode.Instance = Instance.new("Part", workspace.Nodes);
        newNode.Instance.Position = newNode.Position
        newNode.Instance.Anchored = true;
        newNode.Instance.Size = newVec3(2, 2, 2);
        newNode.Instance.CanCollide = false;
    end
    
    Nodes[Pos.X][Pos.Y][Pos.Z] = newNode;
    return Nodes[Pos.X][Pos.Y][Pos.Z];
end

function getNeighbors(node, startPos, endPos, spacing)
    local neighbors = {};
    
    for x = -spacing, spacing, spacing do
      for y = -spacing, spacing, spacing do
        for z = -spacing, spacing, spacing do
            if dimension == "2d" then
                y = 0;
            end

            local vec = node.Position + newVec3(x, y, z);
            local existingNeighbor = nil;
            
            if Config["groundlevel"] and not workspace:FindPartOnRayWithIgnoreList(Ray.new(vec, newVec3(0, -5, 0)), Config["blacklistparts"]) then
                --/ In air
                continue;
            end
            if workspace:FindPartOnRayWithIgnoreList(Ray.new(node.Position, newVec3(x, y, z)), Config["blacklistparts"]) then
                --/ Blocked
                continue;
            end

            if Config["dimension"] == "3d" then
                if Nodes[vec.X] and Nodes[vec.X][vec.Y] and Nodes[vec.X][vec.Y][vec.Z] then
                    existingNeighbor = Nodes[vec.X][vec.Y][vec.Z];
                end
            else
                if Nodes[vec.X] and Nodes[vec.X][vec.Z] then
                    existingNeighbor = Nodes[vec.X][vec.Z];
                end
            end

            if existingNeighbor ~= nil then
                insert(neighbors, existingNeighbor);
            else
                local neighbor = Nodes:New(vec, startPos, endPos);
                cameFrom[neighbor] = node;
                insert(neighbors, neighbor);
            end
        end
      end
    end
    
    return neighbors;
end

--/ Implementation

function recontructPath(currentNode)
    local Path = {};
    local tempCurrent = currentNode
    
    while tempCurrent do
        insert(Path, 1, tempCurrent.Position);
        tempCurrent = cameFrom[tempCurrent];
    end

    return Path;
end

function pathFinder:SetConfiguration(config)
    Config = config
end

function pathFinder:FindPath(startPos, endPos)
    assert(Config, "Please set a configuration first")
    assert(Config["blacklistparts"] ~= nil, "Missing blacklistparts");
    assert(Config["dimension"] ~= nil, "Missing dimension");
    assert(Config["groundlevel"] ~= nil, "Missing groundlevel");
    assert(Config["fast"] ~= nil, "Missing fast");
    assert(Config["spacing"] ~= nil, "Missing spacing");
    assert(Config["showNodes"] ~= nil, "Missing showNodes");
    
    if Config["showNodes"] then
        Instance.new("Folder", workspace).Name = "Nodes";
        insert(Config["blacklistparts"], workspace.Nodes);
    end
    
    local start = tick()
    local startNode = Nodes:New(startPos, startPos, endPos);
    local endNode = Nodes:New(endPos, startPos, endPos)
    
    gScore[startNode] = 0;
    fScore[startNode] = 0;
    
    insert(openNodes, startNode);
    
    while #openNodes > 0 do
        local nodeWithLowestFCost = table.remove(openNodes, 1);
        
        insert(closedNodes, nodeWithLowestFCost);
        
        if Distance(nodeWithLowestFCost.Position, endNode.Position) < Config["spacing"] then
            if workspace:FindPartOnRayWithIgnoreList(Ray.new(nodeWithLowestFCost.Position, endNode.Position - nodeWithLowestFCost.Position), {workspace.Nodes}) then
            --/ Current node is at end node & Path have been found
                return recontructPath(nodeWithLowestFCost);
            end
        end
        
        local Neighbors = getNeighbors(nodeWithLowestFCost, startNode.Position, endNode.Position, waypointSpacing)
        
        for i = 1, #Neighbors do
            local neighbor = Neighbors[i];
            local tempG = gScore[nodeWithLowestFCost] + Distance(nodeWithLowestFCost.Position, neighbor.Position) - 5;

            if not table.find(closedNodes, neighbor) then
                if tempG < gScore[neighbor] or not table.find(openNodes, neighbor) then
                    gScore[neighbor] = tempG;
                    hScore[neighbor] = Distance(neighbor.Position, endNode.Position);
                    fScore[neighbor] = gScore[neighbor] + hScore[neighbor];
                    cameFrom[neighbor] = nodeWithLowestFCost;
                    if not table.find(openNodes, neighbor) then
                        insert(openNodes, neighbor);
                    end
                end
            end
        end
        
        table.sort(openNodes, function(a,b)
            return fScore[a] < fScore[b];
        end)
        
        if Config["fast"] == false then
            task.wait();
        end
    end
end

return pathFinder

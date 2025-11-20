local compBank = {}

local removeCompQ = {}
local removeCompQSize = 0

local killEntityQ = {}

function RegisterComp(name, addFunc)
  compBank[name] = {
    count = 0,
    addFunc = addFunc,
    sparse = {},
    dense = {}
  }
end

function AddComp(entity, name, ...)
  local entry = compBank[name];
  assert(entry.sparse[entity] == nil and "Already has component '"..name.."'")

  entry.count = entry.count + 1
  entry.dense[entry.count] = entity
  entry.sparse[entity] = entry.count

  entry.addFunc(entity, ...)
end

local function RemoveComp(entity, name)
  local entry = compBank[name]
  if entry.sparse[entity] == nil then return end

  local indx = entry.sparse[entity]
  local lastEnt = entry.dense[entry.count]

  entry.dense[indx] = lastEnt
  entry.sparse[lastEnt] = indx

  entry.sparse[entity] = nil
  entry.count = entry.count - 1
end

local function KillEntity(entity)
  for name, entry in pairs(compBank) do
    if entry.sparse[entity] ~= nil then
      RemoveComp(entity, name)
    end
  end
end

function QueueKillEntity(entity)
  table.insert(killEntityQ, entity)
end

function FlushKillEntityQueue()
  for i, entity in ipairs(killEntityQ) do
    KillEntity(entity)
    killEntityQ[i] = nil
  end
end

local function FlushRemoveCompQueue()
  for i = 1, removeCompQSize do
    RemoveComp(removeCompQ[i].entity, removeCompQ[i].comp)
  end
  removeCompQSize = 0
end

function QueueRemoveComp(entity, name)
  removeCompQSize = removeCompQSize + 1
  if removeCompQ[removeCompQSize] == nil then
    removeCompQ[removeCompQSize] = {entity=entity, comp=name}
    return
  end
  removeCompQ[removeCompQSize].entity = entity
  removeCompQ[removeCompQSize].comp = name
end

function HasComp(entity, name)
  return compBank[name].sparse[entity] ~= nil
end

function Query(comp)
  return ipairs(compBank[comp].dense)
end

function RunSystem(sys, ...)
  sys(...)
  FlushKillEntityQueue()
  FlushRemoveCompQueue()
end



local Utils = {}

function Utils:getKeys(t)
  local keys = {}
  for key, _ in pairs(t) do
    table.insert(keys, key)
  end
  return keys
end

function Utils:dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. self:dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

return Utils

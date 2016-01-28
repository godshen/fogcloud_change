local _M = {}
local bit = require "bit"
local crc16 = require "crc16"
local cjson = require "cjson.safe"
local bit = require "bit"
local Json = cjson.encode

local insert = table.insert
local concat = table.concat

local strbyte = string.byte
local strchar = string.char

local cmds = {
  [0x00] = "head1",
  [0x01] = "head2",
  [0x02] = "length",
  [0x03] = "DTU_time",
  [0x04] = "DTU_status",
  [0x05] = "device_address",
  [0x06] = "feedback_speed",
  [0x07] = "given_speed",
  [0x08] = "output_voltage",
  [0x09] = "output_current",
  [0x0a] = "output_torque",
  [0x0b] = "bus_voltage",
  [0x0c] = "anolog_input0",
  [0x0d] = "anolog_input1",
  [0x0e] = "anolog_input2",
  [0x0f] = "cooling_temperature",
  [0x10] = "output_actpow",
  [0x11] = "output_tpow",
  [0x12] = "CRCheck"

}


function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

local function _pack(cmd, data, msg_id)
    local packet = {}

    insert(packet, string.char(0xAA))
    
    return concat(packet, "")
end

local function _unpack(data)
    local packet = {}

    return packet
end

function _M.encode(payload)
    local obj, err = cjson.decode(payload)
    if obj == nil then
        error("json_decode error:"..err)
    end

    for cmd, data in pairs(obj) do
        return _pack(cmd, data)
    end
end
function strTonum( data )
  if data > 96 and data < 103 then
    data = data - 87
  end
  if data > 64 and data < 70 then
    data = data - 55
  end
  if data > 47 and data < 59 then
    data = data - 48
  end
  return data
end
function _M.decode(payload)
    local packet = {}
    packet['status'] = 'not'
    local head1 = string.sub(payload,1,1)
    local head2 = string.sub(payload,2,2)

    if (head1== ';' and head2=='1') then 
      local x = strTonum(string.byte(string.sub(payload,3,3)))
      local y = strTonum(string.byte(string.sub(payload,4,4)))
      packet[ cmds[2] ] = x * 256 + y;
      packet[ cmds[3] ] = strTonum(string.byte(string.sub(payload,5,5))) * 16777216 + strTonum(string.byte(string.sub(payload,6,6))) * 65536 +strTonum(string.byte(string.sub(payload,7,7))) * 256 +strTonum(string.byte(string.sub(payload,8,8)))
      packet[ cmds[4] ] = strTonum(string.byte(string.sub(payload,9,9))) 
      packet[ cmds[5] ] = strTonum(string.byte(string.sub(payload,10,10))) 
      packet['status'] = 'success'

    else
      packet['status'] = 'wrong'

    end

    return Json(packet)
end

--local bin = _pack('eco', '530');
--bin = _M.encode('{"timing-on": 0531}');
--print(string.tohex(bin))
--print(_M.decode(bin))
--print(_M.decode(string.fromhex('aa0010050102030405060708090a051e051e0101010101010101010101010101')))

return _M


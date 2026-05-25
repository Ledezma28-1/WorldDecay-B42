WDecay_Object_Buffer_Types = {}
WDecay_Object_Buffer_Types.IsoObjectType = 1
WDecay_Object_Buffer_Types.IsoTreeType = 2

function WDecay_Object_Buffer_Types.isValidObjectType(type)
    return type and (type == WDecay_Object_Buffer_Types.IsoObjectType or type == WDecay_Object_Buffer_Types.IsoTreeType)
end

return WDecay_Object_Buffer_Types
